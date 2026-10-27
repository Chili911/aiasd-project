"""
server/main.py: the server of your project (FastAPI).
AIASD · Atlas University · Fall 2026-27 · Week 5

Run it from the root of your repository:

    uvicorn server.main:app --reload

then open http://127.0.0.1:8000/docs in the browser: FastAPI lists every endpoint there,
and you can try each one. Stop the server with Ctrl+C.

The rule of this file: every endpoint here is a row of week05/api.md, with the same method
and the same path, and every row of week05/api.md is an endpoint here. The checker
compares the two.
"""

from pathlib import Path
from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI
from server import course_login

app = FastAPI(title="Weatherly — Weather Forecasting and Avatar Styling App")
app.include_router(course_login.router)

@app.get("/health")
def health() -> dict:
    """The server is running. A technical endpoint: it serves no requirement."""
    return {"status": "ok"}
from fastapi import HTTPException


@app.get("/api/weather")
def get_weather(city: str = "") -> dict:
    """REQ-002: Return a simple forecast for a city."""
    if not city.strip():
        raise HTTPException(
            status_code=422,
            detail="City is required",
        )

    return {
        "city": city.strip(),
        "temperature": 18,
        "condition": "Cloudy",
    }

app.mount(
    "/",
    StaticFiles(
        directory=Path(__file__).resolve().parent.parent / "web",
        html=True,
    ),
    name="web",
)