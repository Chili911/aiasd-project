
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

from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from server import course_login

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


app.mount(
    "/",
    StaticFiles(
        directory=Path(__file__).resolve().parent.parent / "web",
        html=True,
    ),
    name="web",
)
