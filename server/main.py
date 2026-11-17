
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

import asyncio
from google import genai
import sqlite3
from datetime import date
from pydantic import BaseModel, Field
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
from server.course_login import current_user

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


# Load the Gemini API key from server/.env
load_dotenv(Path(__file__).resolve().parent / ".env")

# Store daily message counts in SQLite
CHAT_DB = Path(__file__).resolve().parent / "chat_usage.db"


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=2000)


def use_daily_message(user_email: str) -> bool:
    """Allow a maximum of 20 chatbot messages per user per day."""

    today = date.today().isoformat()

    with sqlite3.connect(CHAT_DB) as connection:
        connection.execute("""
            CREATE TABLE IF NOT EXISTS chat_usage (
                user_email TEXT NOT NULL,
                usage_date TEXT NOT NULL,
                message_count INTEGER NOT NULL DEFAULT 0,
                PRIMARY KEY (user_email, usage_date)
            )
        """)

        connection.execute("BEGIN IMMEDIATE")

        result = connection.execute(
            """
            SELECT message_count
            FROM chat_usage
            WHERE user_email = ? AND usage_date = ?
            """,
            (user_email, today)
        ).fetchone()

        if result and result[0] >= 20:
            return False

        connection.execute(
            """
            INSERT INTO chat_usage (user_email, usage_date, message_count)
            VALUES (?, ?, 1)
            ON CONFLICT(user_email, usage_date)
            DO UPDATE SET message_count = message_count + 1
            """,
            (user_email, today)
        )

    return True


@app.post("/chat")
async def chat(
    request: ChatRequest,
    user_email: str = Depends(current_user)
):
    """Answer a logged-in user's weather and outfit questions."""

    api_key = os.getenv("LLM_API_KEY")

    if not api_key:
        raise HTTPException(
            status_code=503,
            detail="AI service is not configured."
        )

    if not use_daily_message(user_email):
        raise HTTPException(
            status_code=429,
            detail="Daily chatbot message limit reached."
        )

    try:
        client = genai.Client(api_key=api_key)

        prompt = f"""
        You are the Weatherly chatbot.
        Help the user with weather-related questions and simple outfit
        recommendations.

        Give clear, short and helpful answers.
        Do not invent live weather information or claim to know the
        user's personal data unless it is provided in the conversation.

        User question: {request.message}
        """

        response = await asyncio.wait_for(
            asyncio.to_thread(
                client.models.generate_content,
                model="gemini-2.5-flash",
                contents=prompt
            ),
            timeout=20
        )

        if not response.text:
            raise RuntimeError("Gemini returned an empty response.")

        return {"answer": response.text}

    except Exception as error:
        print(f"Gemini chat error: {error}")
        raise HTTPException(
            status_code=503,
            detail="AI service is temporarily unavailable."
        )



app.mount(
    "/",
    StaticFiles(
        directory=Path(__file__).resolve().parent.parent / "web",
        html=True,
    ),
    name="web",
)
