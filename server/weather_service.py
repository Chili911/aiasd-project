
import json
import math
import urllib.request
import urllib.parse
from fastapi import HTTPException

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


def search_locations(query, country_code=""):
    query = query.strip()

    if len(query) < 2:
        return []

    params = {
        "name": query,
        "count": 15,
        "language": "en",
        "format": "json"
    }

    if country_code.strip():
        params["countryCode"] = country_code.strip().upper()

    data = fetch_json(GEOCODING_URL, params)

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
        for location in data.get("results", [])
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
            "sunrise,"
            "sunset"
        ),
        "temperature_unit": "celsius",
        "wind_speed_unit": "kmh",
        "timezone": "auto",
        "forecast_days": 7
    })

    try:
        current = data["current"]
        daily = data["daily"]
        forecast = []

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
    condition = (weather.get("condition") or "").lower()

    if maximum is None:
        return ["Temperature data unavailable"]

    if minimum is None:
        minimum = maximum

    average = (maximum + minimum) / 2

    # Base clothing on the average daily temperature.
    if average <= 0:
        outfits = [
            "Winter coat",
            "Thermal clothing",
            "Gloves",
            "Scarf",
            "Winter boots"
        ]

    elif average <= 10:
        outfits = [
            "Warm jacket",
            "Sweater",
            "Long trousers",
            "Closed shoes"
        ]

    elif average <= 18:
        outfits = [
            "Light jacket",
            "Hoodie",
            "Jeans",
            "Sneakers"
        ]

    elif average <= 25:
        outfits = [
            "T-shirt",
            "Light trousers",
            "Sneakers"
        ]

    else:
        outfits = [
            "Lightweight clothing",
            "Shorts",
            "Breathable shoes",
            "Sun hat"
        ]

    # Protect users during colder hours.
    if minimum <= 0:
        outfits.extend([
            "Thermal clothing",
            "Warm gloves",
            "Scarf"
        ])

    elif minimum <= 5:
        outfits.extend([
            "Warm extra layer",
            "Scarf"
        ])

    elif minimum <= 12:
        outfits.append("Extra sweater for cooler hours")

    # Handle large temperature changes.
    if maximum - minimum >= 8:
        outfits.append("Removable layers for temperature changes")

    # Consider warm afternoon temperatures.
    if maximum >= 28:
        outfits.extend([
            "Breathable clothing",
            "Sun hat",
            "Sunglasses"
        ])

    # Rain and drizzle protection.
    if (rain is not None and rain >= 40) or any(
        word in condition
        for word in ("rain", "drizzle", "thunderstorm")
    ):
        outfits.extend([
            "Umbrella",
            "Water-resistant footwear"
        ])

    # Snow protection.
    if "snow" in condition:
        outfits.extend([
            "Waterproof boots",
            "Warm gloves"
        ])

    # Remove duplicate recommendations.
    return list(dict.fromkeys(outfits))



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
