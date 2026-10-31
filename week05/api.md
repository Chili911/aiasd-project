# API contract — Weather Forecasting and Avatar Styling App

| Method | Path | Request | Response | Errors | REQ |
|---|---|---|---|---|---|
| GET | /health | — | 200 {"status": "ok"} | — | — |
| POST | /auth/code | {"email": "khadija.student@example.com"} | 200 {"sent": true} | 422 wrong email format · 429 asked for code too recently | REQ-001 |
| POST | /auth/login | {"email": "khadija.student@example.com", "code": "1234"} | 200 {"token": "session_12345"} | 401 wrong or expired code · 422 email or code missing | REQ-001 |
| GET | /auth/me | — | 200 {"email": "khadija.student@example.com"} | 401 not logged in | REQ-001 |
| GET | /api/weather | ?city=Istanbul | 200 {"city": "Istanbul", "today": {"temperature": 18, "condition": "Cloudy", "precipitation": "20%"}, "tomorrow": {"temperature": 20, "condition": "Rainy", "precipitation": "70%"}} | 422 city missing | REQ-002 |
| GET | /api/outfits | ?city=Ankara | 200 {"city": "Ankara", "today": ["Jacket", "Hoodie"], "tomorrow": ["Umbrella", "Water-resistant footwear"]} | 404 Outfit recommendations unavailable for this location | REQ-003 |
| GET | `/api/avatar` | `?hair=long&makeup=natural&clothing=casual` | 200 `{"hair": "long", "makeup": "natural", "clothing": "casual"}` | 422 invalid hair, makeup, or clothing option | REQ-004 |
