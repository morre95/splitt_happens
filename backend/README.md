# Split Happens backend

A thin gateway in front of [LiteLLM](https://docs.litellm.ai/) that:

- **Caps each user's LLM spend** at a default of **$5.00** (LiteLLM user-level budget).
- **Auto-registers a device** on first contact and keeps logging usage to the **same
  user even when the client's token is refreshed** — identity is the stable `device_id`,
  not the disposable token. (Real login replaces this when the app goes live.)
- Serves an **admin dashboard** to view every user's activity and change / reset budgets.

The Flutter client never holds a spendable key: it sends our opaque app token, and the
FastAPI proxy forwards to LiteLLM using the user's server-side virtual key.

```
Flutter app ──app token──▶ FastAPI ──virtual key──▶ LiteLLM ──OpenRouter key──▶ OpenRouter
```

## Run it

```bash
cd backend
cp .env.example .env        # then fill in real values (never commit .env)
docker compose up --build
```

This starts Postgres, the LiteLLM proxy (`:4000`), and the FastAPI gateway (`:8000`).
FastAPI runs the Alembic migration on startup.

- API: `http://localhost:8000` (`/healthz`, `/auth/register`, `/v1/chat/completions`)
- Admin dashboard: `http://localhost:8000/admin` (log in with `ADMIN_PASSWORD`)

## Configuration (`.env`)

| Variable             | Purpose                                                  |
|----------------------|----------------------------------------------------------|
| `OPENROUTER_API_KEY` | Upstream provider key held centrally by LiteLLM          |
| `LITELLM_MASTER_KEY` | LiteLLM admin key (FastAPI uses it for the admin API)    |
| `LITELLM_BASE_URL`   | Where FastAPI reaches LiteLLM (`http://litellm:4000`)    |
| `DATABASE_URL`       | Postgres URL shared by LiteLLM and FastAPI               |
| `ADMIN_PASSWORD`     | Admin dashboard password                                 |
| `APP_TOKEN_SECRET`   | HMAC secret for hashing client app tokens                |
| `SESSION_SECRET`     | Signs admin session cookies                              |
| `DEFAULT_BUDGET_USD` | Per-user budget applied on first registration (`5.00`)   |

## Endpoints

- `POST /auth/register` — body `{ "device_id": "..." }`; returns
  `{ "success": true, "data": { "token", "budget", "spend" } }`. First call creates the
  LiteLLM user + budget; later calls rotate the token for the **same** user.
- `POST /v1/chat/completions` — OpenAI-format body, `Authorization: Bearer <app token>`.
  Proxies to LiteLLM; budget-exhaustion returns a `BUDGET_EXCEEDED` error.
- `GET /admin` — users list; `GET /admin/users/{litellm_user_id}` — detail with activity,
  change-budget and reset-spend actions.

All errors share one envelope: `{ "success": false, "error": { "code", "message" } }`.

## Tests

```bash
cd app
pip install -e ".[dev]"
python -m pytest
```

## Connecting the Flutter app

Build the app pointing at this backend:

```bash
flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000   # Android emulator
flutter run --dart-define=BACKEND_BASE_URL=http://localhost:8000  # desktop/web/iOS sim
```

No API key needed — the device registers itself on first scan.

## Notes

- LiteLLM image is pinned (`main-v1.83.3-stable`). Spend-reset uses `/user/update`; if a
  future LiteLLM version changes this, update `reset_user_spend` in `app/litellm_client.py`.
- Our only custom table is `devices`; LiteLLM owns its own tables in the same Postgres and
  is only accessed through its API.
