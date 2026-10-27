
from fastapi.testclient import TestClient
from server.main import app

client = TestClient(app)


def test_TC_002_02_weather_forecast():
    response = client.get("/api/weather?city=Istanbul")

    assert response.status_code == 200

    data = response.json()
    assert data["city"] == "Istanbul"
    assert data["temperature"] == 18
    assert data["condition"] == "Cloudy"


def test_TC_002_02_weather_requires_city():
    response = client.get("/api/weather")

    assert response.status_code == 422
