import json
import math
import urllib.request
import urllib.parse
from fastapi import HTTPException
import geonamescache
import unicodedata
from pathlib import Path  


GEOCODING_URL = "https://geocoding-api.open-meteo.com/v1/search"
WEATHER_URL = "https://api.open-meteo.com/v1/forecast"
WEATHER_TIMEOUT = 15


def fetch_json(url, params):
    query = urllib.parse.urlencode(params)

    try:
        with urllib.request.urlopen(
            f"{url}?{query}", timeout=WEATHER_TIMEOUT
        ) as response:
            return json.loads(response.read().decode("utf-8"))

    except (OSError, ValueError) as error:
        raise HTTPException(
            status_code=503,
            detail="Weather service unavailable. Please try again."
        ) from error


def find_city(city):
    city = city.strip()

    if not city:
        raise HTTPException(
            status_code=422,
            detail="City is required."
        )

    data = fetch_json(GEOCODING_URL, {
        "name": city,
        "count": 1,
        "language": "en",
        "format": "json"
    })

    results = data.get("results", [])

    if not results:
        raise HTTPException(
            status_code=404,
            detail="No matching locations found."
        )

    return results[0]

gc = geonamescache.GeonamesCache()
COUNTRIES = gc.get_countries()
CITIES = gc.get_cities()

REGIONS = {}

region_file = Path(__file__).parent / "data" / "admin1CodesASCII.txt"

with region_file.open(encoding="utf-8") as file:
    for line in file:
        parts = line.strip().split("\t")
        if len(parts) >= 3:
            REGIONS[parts[0]] = parts[1]

def normalize_name(value):
    value = unicodedata.normalize("NFKD", value)
    return "".join(
        c for c in value
        if not unicodedata.combining(c)
    ).casefold().strip()


def find_country_code(name):
    normalized = normalize_name(name)

    aliases = {
        "turkey": "TR",
        "turkiye": "TR",
        "republic of turkiye": "TR",
        "uk": "GB",
        "usa": "US",
        "united states of america": "US",
        "uae": "AE",
    }

    if normalized in aliases:
        return aliases[normalized]

    for code, country in COUNTRIES.items():
        if normalized in (
            normalize_name(country["name"]),
            country["iso"].lower(),
            country["iso3"].lower()
        ):
            return code

    return ""


def search_locations(query, country_code=""):
    query = query.strip()
    country_code = country_code.strip().upper()

    if len(query) < 2:
        return []

    # Support searches such as Berlin, Germany.
    if "," in query:
        city_name, country_name = query.rsplit(",", 1)
        detected_code = find_country_code(country_name)

        if detected_code:
            query = city_name.strip()
            country_code = detected_code


    # Search cities within a selected province or state.
    if country_code:
        matching_regions = [
            code for code, name in REGIONS.items()
            if code.startswith(country_code + ".")
            and normalize_name(name) == normalize_name(query)
        ]

        if matching_regions:
            cities = [
                city for city in CITIES.values()
                if city["countrycode"] == country_code
                and (
                    country_code + "." + city["admin1code"]
                ) in matching_regions
            ]

            cities.sort(
                key=lambda city: city.get("population", 0),
                reverse=True
            )

            return [
                {
                    "id": city["geonameid"],
                    "city": city["name"],
                    "country": COUNTRIES[country_code]["name"],
                    "country_code": country_code,
                    "region": REGIONS.get(
                        country_code + "." + city["admin1code"], ""
                    ),
                    "latitude": city["latitude"],
                    "longitude": city["longitude"],
                    "timezone": city.get("timezone", "auto")
                }
                for city in cities[:15]
            ]
        
    # Country searches return major cities.
    detected_country = find_country_code(query)

    if detected_country and (
    not country_code or detected_country == country_code
):
        country = COUNTRIES[detected_country]

        cities = [
            city for city in CITIES.values()
            if city["countrycode"] == detected_country
        ]

        cities.sort(
            key=lambda city: (
                normalize_name(city["name"]) ==
                normalize_name(country["capital"]),
                city.get("population", 0)
            ),
            reverse=True
        )

        return [
            {
                "id": city["geonameid"],
                "city": city["name"],
                "country": country["name"],
                "country_code": detected_country,
                "region": "",
                "latitude": city["latitude"],
                "longitude": city["longitude"],
                "timezone": city.get("timezone", "auto")
            }
            for city in cities[:15]
        ]

    # Normal worldwide city search.
    params = {
        "name": query,
        "count": 30,
        "language": "en",
        "format": "json"
    }

    if country_code:
        params["countryCode"] = country_code

    data = fetch_json(GEOCODING_URL, params)

    results = [
        location
        for location in data.get("results", [])
        if location.get("feature_code", "").startswith("PPL")
        and (
            not country_code
            or location.get("country_code") == country_code
        )
    ]

    # Prioritize exact city names and larger populations.
    results.sort(
        key=lambda location: (
            normalize_name(location["name"]) ==
            normalize_name(query),
            location.get("population") or 0
        ),
        reverse=True
    )

    return [
        {
            "id": location["id"],
            "city": location["name"],
            "country": location.get("country", ""),
            "country_code": location.get("country_code", ""),
            "region": location.get("admin1", ""),
            "latitude": location["latitude"],
            "longitude": location["longitude"],
            "timezone": location.get("timezone", "auto")
        }
        for location in results[:15]
    ]


# Resolve the exact selected location.
def resolve_location(
    city="",
    latitude=None,
    longitude=None,
    country=""
):
    # Preserve the existing city-name search.
    if latitude is None and longitude is None:
        return find_city(city)

    # Both coordinates must be supplied together.
    if latitude is None or longitude is None:
        raise HTTPException(
            status_code=422,
            detail="Both latitude and longitude are required."
        )

    try:
        latitude = float(latitude)
        longitude = float(longitude)
    except (TypeError, ValueError):
        raise HTTPException(
            status_code=422,
            detail="Invalid location coordinates."
        )

    if not math.isfinite(latitude) or not math.isfinite(longitude):
        raise HTTPException(
            status_code=422,
            detail="Coordinates must be finite numbers."
        )

    if not -90 <= latitude <= 90:
        raise HTTPException(
            status_code=422,
            detail="Latitude must be between -90 and 90."
        )

    if not -180 <= longitude <= 180:
        raise HTTPException(
            status_code=422,
            detail="Longitude must be between -180 and 180."
        )

    # Use the selected coordinates without searching again.
    return {
        "name": city.strip() or "Selected location",
        "country": country.strip(),
        "latitude": latitude,
        "longitude": longitude
    }


def weather_condition(code):
    conditions = {
        0: "Clear sky",
        1: "Mostly clear",
        2: "Partly cloudy",
        3: "Cloudy",
        45: "Foggy",
        48: "Foggy",
        51: "Light drizzle",
        53: "Drizzle",
        55: "Heavy drizzle",
        56: "Freezing drizzle",
        57: "Freezing drizzle",
        61: "Light rain",
        63: "Rainy",
        65: "Heavy rain",
        66: "Freezing rain",
        67: "Freezing rain",
        71: "Light snow",
        73: "Snowy",
        75: "Heavy snow",
        77: "Snow grains",
        80: "Light rain showers",
        81: "Rain showers",
        82: "Heavy rain showers",
        85: "Snow showers",
        86: "Heavy snow showers",
        95: "Thunderstorm",
        96: "Thunderstorm with hail",
        99: "Severe thunderstorm with hail"
    }

    return conditions.get(code, "Unknown")


def get_live_weather(
    city="",
    latitude=None,
    longitude=None,
    country=""
):
    location = resolve_location(
        city=city,
        latitude=latitude,
        longitude=longitude,
        country=country
    )

    data = fetch_json(WEATHER_URL, {
        "latitude": location["latitude"],
        "longitude": location["longitude"],
        "current": (
            "temperature_2m,"
            "relative_humidity_2m,"
            "apparent_temperature,"
            "weather_code,"
            "wind_speed_10m,"
            "is_day"
        ),
        "daily": (
            "weather_code,"
            "temperature_2m_max,"
            "temperature_2m_min,"
            "precipitation_probability_max,"
            "apparent_temperature_max,"
            "apparent_temperature_min,"
            "wind_speed_10m_max,"
            "sunrise,"
            "sunset"
        ),

        "hourly": (
            "temperature_2m,"
            "weather_code,"
            "precipitation_probability,"
            "is_day"
        ),
        "temperature_unit": "celsius",
        "wind_speed_unit": "kmh",
        "timezone": "auto",
        "forecast_days": 7
    })

    try:
        current = data["current"]
        daily = data["daily"]
        hourly = data["hourly"]
        forecast = []
        hourly_forecast = []

        # Return the next 24 hourly forecasts in the selected city's local time.
        for i, hour in enumerate(hourly["time"]):
            if hour < current["time"]:
                continue

            hourly_forecast.append({
                "time": hour,
                "temperature": hourly["temperature_2m"][i],
                "condition": weather_condition(
                    hourly["weather_code"][i]
                ),
                "rain_probability": hourly["precipitation_probability"][i],
                "is_day": hourly["is_day"][i]
            })

            if len(hourly_forecast) >= 24:
                break

        for i, date in enumerate(daily["time"]):
            rain = daily["precipitation_probability_max"][i]

            forecast.append({
                "date": date,
                "temperature": daily["temperature_2m_max"][i],
                "min_temperature": daily["temperature_2m_min"][i],
                "max_temperature": daily["temperature_2m_max"][i],
                "condition": weather_condition(
                    daily["weather_code"][i]
                ),
                "precipitation": (
                    f"{rain}%" if rain is not None else None
                ),
                "rain_probability": rain,
                "feels_like_min": daily["apparent_temperature_min"][i],
                "feels_like_max": daily["apparent_temperature_max"][i],
                "wind_speed": daily["wind_speed_10m_max"][i],
                "sunrise": daily["sunrise"][i],
                "sunset": daily["sunset"][i]
            })

        if len(forecast) < 2:
            raise ValueError("Incomplete forecast")

        return {
            "city": location["name"],
            "country": location.get("country"),
            "latitude": location["latitude"],
            "longitude": location["longitude"],
            "timezone": data["timezone"],
            "current": {
                "temperature": current["temperature_2m"],
                "feels_like": current["apparent_temperature"],
                "humidity": current["relative_humidity_2m"],
                "wind_speed": current["wind_speed_10m"],
                "condition": weather_condition(
                    current["weather_code"]
                ),
                "is_day": current["is_day"],
                "time": current["time"]
            },
            "today": forecast[0],
            "tomorrow": forecast[1],
            "forecast": forecast,
            "hourly": hourly_forecast,
            "source": "Open-Meteo"
        }

    except (KeyError, IndexError, TypeError, ValueError) as error:
        raise HTTPException(
            status_code=503,
            detail="Incomplete weather data received."
        ) from error



def recommend_clothing(weather):
    maximum = weather.get("max_temperature", weather.get("temperature"))
    minimum = weather.get("min_temperature")
    rain = weather.get("rain_probability")
    wind = weather.get("wind_speed") or 0
    condition = (weather.get("condition") or "").lower()

    if maximum is None:
        return ["Temperature data unavailable"]
    if minimum is None:
        minimum = maximum

    feels_min = weather.get("feels_like_min")
    feels_max = weather.get("feels_like_max")
    feels_min = minimum if feels_min is None else feels_min
    feels_max = maximum if feels_max is None else feels_max
    average = (feels_min + feels_max) / 2

    # Choose one coordinated outfit based on daily apparent temperature.
    if average <= -5:
        outer, top, bottom, shoes = "Heavy winter coat", "Thermal base layer and fleece", "Insulated trousers", "Insulated winter boots"
    elif average <= 0:
        outer, top, bottom, shoes = "Insulated winter coat", "Wool sweater", "Thermal-lined trousers", "Winter boots"
    elif average <= 5:
        outer, top, bottom, shoes = "Puffer jacket", "Thick sweater", "Warm trousers", "Ankle boots"
    elif average <= 9:
        outer, top, bottom, shoes = "Warm jacket", "Knit sweater", "Jeans", "Closed shoes"
    elif average <= 13:
        outer, top, bottom, shoes = "Medium-weight jacket", "Long-sleeve shirt", "Jeans", "Sneakers"
    elif average <= 17:
        outer, top, bottom, shoes = "Light jacket", "Light sweater", "Chinos", "Sneakers"
    elif average <= 21:
        outer, top, bottom, shoes = "Light cardigan", "Cotton T-shirt", "Light trousers", "Sneakers"
    elif average <= 25:
        outer, top, bottom, shoes = None, "Cotton T-shirt", "Light trousers", "Breathable sneakers"
    elif average <= 30:
        outer, top, bottom, shoes = None, "Linen shirt", "Lightweight trousers", "Breathable shoes"
    else:
        outer, top, bottom, shoes = None, "Loose breathable top", "Shorts or loose linen trousers", "Breathable sandals"

    accessories = []
    if feels_min <= 0:
        accessories.extend(["Thermal base layer", "Warm gloves", "Scarf", "Warm hat"])
    elif feels_min <= 5:
        accessories.extend(["Scarf", "Warm gloves"])
    elif feels_min <= 12:
        accessories.append("Extra removable layer for cooler hours")
    if feels_max - feels_min >= 8:
        accessories.append("Removable layers for temperature changes")
    if feels_max >= 28 or ("clear" in condition and feels_max >= 20):
        accessories.extend(["Sun hat", "Sunglasses"])

    # Adjust outerwear and footwear rather than adding conflicting items.
    wet = (rain is not None and rain >= 40) or any(
        word in condition for word in ("rain", "drizzle", "thunderstorm")
    )
    snowy = "snow" in condition or "freezing" in condition
    if snowy:
        outer = "Insulated waterproof winter coat"
        shoes = "Insulated waterproof boots"
        accessories.extend(["Warm gloves", "Warm hat"])
    elif wet:
        if average <= 0:
            outer = "Insulated waterproof winter coat"
            shoes = "Insulated waterproof boots"
        elif average <= 13:
            outer = "Warm waterproof jacket"
            shoes = "Waterproof boots"
        else:
            outer = "Light waterproof rain jacket"
            shoes = "Water-resistant shoes"

        if wind < 35 and "thunderstorm" not in condition:
            accessories.append("Umbrella")
        else:
            accessories.append("Waterproof hood")

    elif wind >= 25:
        if average <= 0:
            outer = "Insulated windproof winter coat"
        elif average <= 5:
            outer = "Windproof puffer jacket"
        elif average <= 13:
            outer = "Wind-resistant warm jacket"
        else:
            outer = "Light windbreaker"

    if wind >= 35:
        accessories.append("Secure hood or hat for strong wind")
    if "thunderstorm" in condition:
        accessories.append("Avoid outdoor exposure during thunderstorms")

    outfits = [item for item in (outer, top, bottom, shoes) if item]
    return list(dict.fromkeys(outfits + accessories))


# Generate outfits for the exact selected location.
def get_live_outfits(
    city="",
    latitude=None,
    longitude=None,
    country=""
):
    weather = get_live_weather(
        city=city,
        latitude=latitude,
        longitude=longitude,
        country=country
    )

    forecast = []

    for day in weather["forecast"]:
        forecast.append({
            "date": day["date"],
            "temperature": day["temperature"],
            "min_temperature": day["min_temperature"],
            "max_temperature": day["max_temperature"],
            "condition": day["condition"],
            "rain_probability": day["rain_probability"],
            "feels_like_min": day["feels_like_min"],
            "feels_like_max": day["feels_like_max"],
            "wind_speed": day["wind_speed"],
            "outfits": recommend_clothing(day)
        })

    return {
        "city": weather["city"],
        "country": weather["country"],
        "latitude": weather["latitude"],
        "longitude": weather["longitude"],
        "timezone": weather["timezone"],
        "today": forecast[0]["outfits"],
        "tomorrow": forecast[1]["outfits"],
        "current_temperature": weather["current"]["temperature"],
        "current_condition": weather["current"]["condition"],
        "forecast": forecast,
        "source": "Open-Meteo"
    }
