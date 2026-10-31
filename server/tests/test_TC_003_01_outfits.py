from fastapi.testclient import TestClient

from server.main import app

client = TestClient(app)


def test_TC_003_01_cooler_rainy_weather_recommendations():
    response = client.get("/api/outfits?city=Ankara")

    assert response.status_code == 200

    data = response.json()
    assert data["city"] == "Ankara"
    assert "Jacket" in data["today"]
    assert "Hoodie" in data["today"]
    assert "Umbrella" in data["tomorrow"]
    assert "Water-resistant footwear" in data["tomorrow"]


def test_TC_003_02_missing_weather_data_shows_error():
    response = client.get("/api/outfits?city=Paris")

    assert response.status_code == 404
    assert response.json()["detail"] == (
        "Outfit recommendations unavailable for this location"
    )