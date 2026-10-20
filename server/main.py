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

from fastapi import FastAPI

app = FastAPI(title="Weatherly — Weather Forecasting and Avatar Styling App")

@app.get("/health")
def health() -> dict:
    """The server is running. A technical endpoint: it serves no requirement."""
    return {"status": "ok"}

from fastapi.responses import JSONResponse


@app.post("/auth/code")
def request_login_code() -> JSONResponse:
    """REQ-001: Request an email login code. Not implemented in Week 5."""
    return JSONResponse(
        status_code=501,
        content={"detail": "Login code requests are not implemented yet."},
    )


@app.post("/auth/login")
def login_with_code() -> JSONResponse:
    """REQ-001: Log in with an email code. Not implemented in Week 5."""
    return JSONResponse(
        status_code=501,
        content={"detail": "Login is not implemented yet."},
    )