"""
Weatherly - FastAPI Backend
AIASD - Atlas University - Fall 2026-27

Live weather forecasts, dynamic outfit recommendations,
avatar customization, authentication and AI chatbot.

All endpoints must match week05/api.md.
"""

import json
import os
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from threading import Lock

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles


# Environment configuration
ROOT_DIR = Path(__file__).resolve().parent.parent

load_dotenv(ROOT_DIR / ".env")
load_dotenv(ROOT_DIR / "server" / ".env")

from server import course_login
from server.email_service import send_verification_email
from server.weather_service import (
    get_live_weather,
    recommend_clothing,
    search_locations
)


# Groq AI configuration
GROQ_MODEL = os.getenv("GROQ_MODEL", "openai/gpt-oss-20b")
CHAT_DAILY_LIMIT = int(os.getenv("CHAT_DAILY_LIMIT", "20"))
GROQ_TIMEOUT = int(os.getenv("GROQ_TIMEOUT", "20"))

_chat_usage: dict[tuple[str, str], int] = {}
_chat_usage_lock = Lock()


# Groq chatbot service
def get_groq_answer(message: str) -> str:
    api_key = os.getenv("LLM_API_KEY", "").strip()

    if not api_key:
        raise HTTPException(
            status_code=503,
            detail="AI API key is not configured."
        )

    payload = {
        "model": GROQ_MODEL,
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are Weatherly's helpful weather and outfit assistant. "
                    "Answer questions about weather and suitable clothing. "
                    "Give simple, clear and friendly suggestions. "
                    "Keep answers short and practical. "
                    "Use plain text and simple bullet points, not tables. "
                    "Do not invent live weather information. "
                    "Do not claim to access personal user data that has not been provided. "
                    "If current weather information is unavailable, say so."
                )
            },
            {
                "role": "user",
                "content": message
            }
        ]
    }

    request = urllib.request.Request(
        "https://api.groq.com/openai/v1/chat/completions",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": "Weatherly/1.0"
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(
            request, timeout=GROQ_TIMEOUT
        ) as response:
            result = json.loads(response.read().decode("utf-8"))

        answer = result["choices"][0]["message"]["content"]

        if not isinstance(answer, str) or not answer.strip():
            raise ValueError("AI returned an empty answer.")

        return answer.strip()

    except urllib.error.HTTPError as error:
        print(f"Groq API error: HTTP {error.code}")

        if error.code == 429:
            raise HTTPException(
                status_code=429,
                detail="AI usage limit reached. Please try again later."
            ) from error

        raise HTTPException(
            status_code=503,
            detail="The AI service is currently unavailable. Please try again."
        ) from error

    except (
        urllib.error.URLError,
        TimeoutError,
        OSError,
        ValueError,
        KeyError,
        IndexError,
        TypeError
    ) as error:
        print(f"Groq service error: {type(error).__name__}")

        raise HTTPException(
            status_code=503,
            detail="The AI service is currently unavailable. Please try again."
        ) from error


# FastAPI application
app = FastAPI(
    title="Weatherly",
    description="Live weather forecasts, outfit recommendations and AI assistance.",
    version="2.0.0"
)


# Flexible CORS configuration
allowed_origins = [
    origin.strip()
    for origin in os.getenv("CORS_ORIGINS", "").split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_origin_regex=os.getenv(
        "CORS_ORIGIN_REGEX",
        r"https?://(localhost|127\.0\.0\.1)(:\d+)?$"
    ),
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"]
)


# Email delivery configuration
original_deliver = course_login._deliver

def deliver_verification_code(email: str, code: str) -> None:
    # Preserve the professor's automated testing method
    if os.getenv("AIASD_CODE_FILE"):
        original_deliver(email, code)

    # Use EmailJS when configured on Render
    elif os.getenv("EMAILJS_SERVICE_ID"):
        send_verification_email(email, code)

    # Preserve the original SMTP method for local development
    else:
        original_deliver(email, code)


# Connect EmailJS without editing the course file
course_login._deliver = deliver_verification_code


# Authentication endpoints
app.include_router(course_login.router)


# Server health endpoint
@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/api/countries")
def get_countries() -> dict:
    from server.weather_service import COUNTRIES

    countries = [
        {
            "code": code,
            "name": "Türkiye" if code == "TR" else country["name"]
        }
        for code, country in COUNTRIES.items()
    ]

    countries.sort(key=lambda country: country["name"])
    return {"countries": countries}

# Worldwide location search
@app.get("/api/locations")
def get_locations(query: str = "", country_code: str = "") -> dict:
    """Search worldwide locations."""
    return {
        "locations": search_locations(query, country_code)
    }


# REQ-002: Live weather forecasts
@app.get("/api/weather")
def get_weather(
    city: str = "",
    latitude: float | None = None,
    longitude: float | None = None,
    country: str = ""
) -> dict:
    return get_live_weather(
        city=city,
        latitude=latitude,
        longitude=longitude,
        country=country
    )


# REQ-003: Dynamic outfit recommendations
@app.get("/api/outfits")
def get_outfits(
    city: str = "",
    latitude: float | None = None,
    longitude: float | None = None,
    country: str = ""
) -> dict:
    """Recommend clothing based on actual weather conditions."""

    weather = get_live_weather(
        city=city,
        latitude=latitude,
        longitude=longitude,
        country=country
    )

    return {
        "city": weather["city"],
        "country": weather["country"],
        "latitude": weather["latitude"],
        "longitude": weather["longitude"],
        "today": recommend_clothing(weather["today"]),
        "tomorrow": recommend_clothing(weather["tomorrow"]),
        "current_temperature": weather["current"]["temperature"],
        "current_condition": weather["current"]["condition"],
        "forecast": [
            {
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
            }
            for day in weather["forecast"]
        ],
        "source": weather["source"]
    }


# REQ-004: Avatar customization
@app.get("/api/avatar")
def get_avatar(
    hair: str = "long",
    makeup: str = "natural",
    clothing: str = "casual"
) -> dict:

    allowed_hair = ["long", "short", "curly"]
    allowed_makeup = ["natural", "soft", "bold"]
    allowed_clothing = ["casual", "formal", "sporty"]

    if hair not in allowed_hair:
        raise HTTPException(
            status_code=422,
            detail="Invalid hair option"
        )

    if makeup not in allowed_makeup:
        raise HTTPException(
            status_code=422,
            detail="Invalid makeup option"
        )

    if clothing not in allowed_clothing:
        raise HTTPException(
            status_code=422,
            detail="Invalid clothing option"
        )

    return {
        "hair": hair,
        "makeup": makeup,
        "clothing": clothing
    }


# REQ-010: AI chatbot
@app.post("/chat")
def chat(
    body: dict,
    user: str = Depends(course_login.current_user)
) -> dict:

    message = body.get("message")

    if not isinstance(message, str) or not message.strip():
        raise HTTPException(
            status_code=422,
            detail="A chat message is required."
        )

    message = message.strip()

    if len(message) > 2000:
        raise HTTPException(
            status_code=422,
            detail="The message must be 2000 characters or fewer."
        )

    today = datetime.now(timezone.utc).date().isoformat()
    usage_key = (user, today)

    with _chat_usage_lock:

        for old_key in list(_chat_usage):
            if old_key[1] != today:
                del _chat_usage[old_key]

        if _chat_usage.get(usage_key, 0) >= CHAT_DAILY_LIMIT:
            raise HTTPException(
                status_code=429,
                detail=f"You have reached your daily limit of {CHAT_DAILY_LIMIT} messages."
            )

        _chat_usage[usage_key] = _chat_usage.get(usage_key, 0) + 1

    try:
        answer = get_groq_answer(message)

    except HTTPException:
        with _chat_usage_lock:
            if usage_key in _chat_usage:
                _chat_usage[usage_key] -= 1
        raise

    return {"answer": answer}


# Existing web frontend
WEB_DIR = ROOT_DIR / "web"

if WEB_DIR.is_dir():
    app.mount(
        "/",
        StaticFiles(
            directory=WEB_DIR,
            html=True
        ),
        name="web"
    )


# Configurable server startup
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        app,
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8000"))
    )