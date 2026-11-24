import os
import json
import urllib.request
import urllib.error
from fastapi import HTTPException


def send_verification_email(email: str, code: str) -> None:
    service_id = os.getenv("EMAILJS_SERVICE_ID")
    template_id = os.getenv("EMAILJS_TEMPLATE_ID")
    public_key = os.getenv("EMAILJS_PUBLIC_KEY")
    private_key = os.getenv("EMAILJS_PRIVATE_KEY")

    if not all([service_id, template_id, public_key, private_key]):
        raise HTTPException(
            status_code=503,
            detail="EmailJS configuration is missing."
        )

    payload = {
        "service_id": service_id,
        "template_id": template_id,
        "user_id": public_key,
        "accessToken": private_key,
        "template_params": {
            "email": email,
            "passcode": code
        }
    }

    request = urllib.request.Request(
        "https://api.emailjs.com/api/v1.0/email/send",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )

    try:
        with urllib.request.urlopen(request, timeout=20):
            pass
    except urllib.error.HTTPError as error:
        print(f"EmailJS HTTP error: {error.code}")
        raise HTTPException(
            status_code=503,
            detail="EmailJS could not send the verification email."
        ) from error
    except (OSError, urllib.error.URLError) as error:
        raise HTTPException(
            status_code=503,
            detail="Could not connect to EmailJS."
        ) from error