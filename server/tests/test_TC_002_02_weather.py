
from fastapi.testclient import TestClient
from server.main import app

client = TestClient(app)


def test_TC_002_02_weather_forecast():
    response = client.get("/api/weather?city=Istanbul")

    assert response.status_code == 200

    data = response.json()
    assert data["city"] == "Istanbul"

    assert data["today"]["temperature"] == 18
    assert data["today"]["condition"] == "Cloudy"
    assert data["today"]["precipitation"] == "20%"

    assert data["tomorrow"]["temperature"] == 20
    assert data["tomorrow"]["condition"] == "Rainy"
    assert data["tomorrow"]["precipitation"] == "70%"


def test_TC_002_02_weather_requires_city():
    response = client.get("/api/weather")

    assert response.status_code == 422
