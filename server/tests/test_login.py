"""REQ-001: Tests for email-code login."""

import os
import tempfile
from pathlib import Path

from fastapi.testclient import TestClient

from server import course_login
from server.main import app

client = TestClient(app)


def request_login_code(email: str) -> str:
    """Request a login code and read it from a temporary file."""
    with tempfile.TemporaryDirectory() as folder:
        code_file = Path(folder) / "login_code.txt"
        previous_file = os.environ.get("AIASD_CODE_FILE")
        os.environ["AIASD_CODE_FILE"] = str(code_file)

        try:
            response = client.post(
                "/auth/code",
                json={"email": email},
            )
            assert response.status_code == 200
            return code_file.read_text(encoding="utf-8").strip()
        finally:
            if previous_file is None:
                os.environ.pop("AIASD_CODE_FILE", None)
            else:
                os.environ["AIASD_CODE_FILE"] = previous_file


def test_TC_001_01_log_in_with_the_correct_code():
    email = "student@example.test"
    course_login.reset_for_tests()
    code = request_login_code(email)

    response = client.post(
        "/auth/login",
        json={"email": email, "code": code},
    )

    assert response.status_code == 200


def test_TC_001_02_a_wrong_code_is_refused():
    email = "wrong-code@example.test"
    course_login.reset_for_tests()
    request_login_code(email)

    response = client.post(
        "/auth/login",
        json={"email": email, "code": "wrong"},
    )

    assert response.status_code == 401


def test_TC_001_04_an_expired_login_code_is_refused():
    email = "expired-code@example.test"
    course_login.reset_for_tests()
    code = request_login_code(email)

    course_login._pending[email] = course_login._Pending(
        code=code,
        sent_at=0,
    )

    response = client.post(
        "/auth/login",
        json={"email": email, "code": code},
    )

    assert response.status_code == 401

def test_TC_001_03_an_empty_email_is_refused():
    response = client.post(
        "/auth/code",
        json={"email": ""},
    )

    assert response.status_code == 422