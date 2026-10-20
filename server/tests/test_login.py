
"""REQ-001: Tests for email-code login."""

from fastapi.testclient import TestClient

from server.main import app

client = TestClient(app)


def test_TC_001_01_log_in_with_the_correct_code():
    response = client.post(
        "/auth/login",
        json={"email": "student@example.test", "code": "1234"},
    )

    assert response.status_code == 200
