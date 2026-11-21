
"""
server/main.py: the server of your project (FastAPI).
AIASD - Atlas University - Fall 2026-27 - Week 5

Run it from the root of your repository:

    uvicorn server.main:app --reload

then open http://127.0.0.1:8000/docs in the browser: FastAPI lists every endpoint there,
and you can try each one. Stop it with Ctrl+C.

The rule of this file: every endpoint here is a row of week05/api.md, with the same method
and the same path, and every row of week05/api.md is an endpoint here. The checker
compares the two.
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

from server import course_login

load_dotenv(Path(__file__).resolve().parent / ".env")

# Gemini chatbot settings
GEMINI_MODEL = "gemini-3.8-flash"
CHAT_DAILY_LIMIT = 20
GEMINI_TIMEOUT = 20

# Store message counts separately for each user and UTC date.
# This counter is in memory and resets when the server restarts.
_chat_usage: dict[tuple[str, str], int] = {}
_chat_usage_lock = Lock()


def get_gemini_answer(message: str) -> str:
    """Send the user's message to Google Gemini and return its answer."""

    api_key = os.getenv("LLM_API_KEY", "").strip()

    if not api_key:
        raise HTTPException(
            status_code=503,
            detail="Gemini API key is not configured.",
        )

    payload = {
        "systemInstruction": {
            "parts": [
                {
                    "text": (
                        "You are Weatherly's helpful weather and outfit assistant. "
                        "Answer questions about weather and suitable clothing. "
                        "Give simple, clear and friendly suggestions. "
                        "Do not invent live weather information or claim to access "
                        "personal user data that has not been provided. "
                        "If current weather information is unavailable, say so."
                    )
                }
            ]
        },
        "contents": [
            {
                "role": "user",
                "parts": [{"text": message}],
            }
        ],
    }

    request = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/"
        f"{GEMINI_MODEL}:generateContent",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "x-goog-api-key": api_key,
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(
            request,
            timeout=GEMINI_TIMEOUT,
        ) as response:
            result = json.loads(response.read().decode("utf-8"))

        answer = result["candidates"][0]["content"]["parts"][0]["text"]

        if not isinstance(answer, str) or not answer.strip():
            raise ValueError("Gemini returned an empty answer.")

        return answer.strip()

    except (
        urllib.error.URLError,
        urllib.error.HTTPError,
        TimeoutError,
        OSError,
        ValueError,
        KeyError,
        IndexError,
        TypeError,
    ) as error:
        raise HTTPException(
            status_code=503,
            detail="The AI service is currently unavailable. Please try again.",
        ) from error

app = FastAPI(title="Weatherly - Weather Forecasting and Avatar Styling App")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8081",
        "http://127.0.0.1:8081",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(course_login.router)


@app.get("/health")
def health() -> dict:
    """The server is running. A technical endpoint: it serves no requirement."""
    return {"status": "ok"}


@app.get("/api/weather")
def get_weather(city: str = "") -> dict:
    """REQ-002: Return today's and tomorrow's forecast for a supported city."""
    city = city.strip()

    if not city:
        raise HTTPException(
            status_code=422,
            detail="City is required",
        )

    if city.lower() != "istanbul":
        raise HTTPException(
            status_code=404,
            detail="No matching locations found.",
        )

    return {
        "city": city,
        "today": {
            "temperature": 18,
            "condition": "Cloudy",
            "precipitation": "20%",
        },
        "tomorrow": {
            "temperature": 20,
            "condition": "Rainy",
            "precipitation": "70%",
        },
    }


@app.get("/api/outfits")
def get_outfits(city: str = "") -> dict:
    """REQ-003: Recommend clothing based on the forecast."""
    city = city.strip()

    if city.lower() == "ankara":
        return {
            "city": "Ankara",
            "today": ["Jacket", "Hoodie"],
            "tomorrow": ["Umbrella", "Water-resistant footwear"],
        }

    raise HTTPException(
        status_code=404,
        detail="Outfit recommendations unavailable for this location",
    )


@app.get("/api/avatar")
def get_avatar(
    hair: str = "long",
    makeup: str = "natural",
    clothing: str = "casual",
) -> dict:
    """REQ-004: Return the selected avatar appearance options."""
    allowed_hair = ["long", "short", "curly"]
    allowed_makeup = ["natural", "soft", "bold"]
    allowed_clothing = ["casual", "formal", "sporty"]

    if hair not in allowed_hair:
        raise HTTPException(status_code=422, detail="Invalid hair option")

    if makeup not in allowed_makeup:
        raise HTTPException(status_code=422, detail="Invalid makeup option")

    if clothing not in allowed_clothing:
        raise HTTPException(status_code=422, detail="Invalid clothing option")

    return {
        "hair": hair,
        "makeup": makeup,
        "clothing": clothing,
    }



@app.post("/chat")
def chat(
    body: dict,
    user: str = Depends(course_login.current_user),
) -> dict:
    """REQ-010: Answer weather and outfit questions using Gemini."""

    message = body.get("message")

    if not isinstance(message, str) or not message.strip():
        raise HTTPException(
            status_code=422,
            detail="A chat message is required.",
        )

    message = message.strip()

    if len(message) > 2000:
        raise HTTPException(
            status_code=422,
            detail="The message must be 2000 characters or fewer.",
        )

    today = datetime.now(timezone.utc).date().isoformat()
    usage_key = (user, today)

    with _chat_usage_lock:
        # Remove usage records from previous days.
        for old_key in list(_chat_usage):
            if old_key[1] != today:
                del _chat_usage[old_key]

        if _chat_usage.get(usage_key, 0) >= CHAT_DAILY_LIMIT:
            raise HTTPException(
                status_code=429,
                detail="You have reached your daily limit of 20 messages.",
            )

        # Reserve one message slot.
        _chat_usage[usage_key] = _chat_usage.get(usage_key, 0) + 1

    try:
        answer = get_gemini_answer(message)
    except HTTPException:
        # Do not charge the user for a failed Gemini request.
        with _chat_usage_lock:
            _chat_usage[usage_key] -= 1
        raise

    return {"answer": answer}




app.mount(
    "/",
    StaticFiles(
        directory=Path(__file__).resolve().parent.parent / "web",
        html=True,
    ),
    name="web",
)
