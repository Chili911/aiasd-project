from fastapi.testclient import TestClient

from server.main import app

client = TestClient(app)


def test_TC_004_01_avatar_customization():
    response = client.get(
        "/api/avatar?hair=curly&makeup=bold&clothing=sporty"
    )

    assert response.status_code == 200

    data = response.json()
    assert data["hair"] == "curly"
    assert data["makeup"] == "bold"
    assert data["clothing"] == "sporty"


def test_avatar_rejects_invalid_hair():
    response = client.get("/api/avatar?hair=unknown")

    assert response.status_code == 422
    assert response.json()["detail"] == "Invalid hair option"