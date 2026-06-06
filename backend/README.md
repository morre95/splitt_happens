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

## Run locally

Requires **Docker** with the Compose plugin (`docker compose version`).

```bash
cd backend
cp .env.example .env        # then fill in real values (never commit .env)
docker compose up --build
```

This starts Postgres, the LiteLLM proxy (`:4000`), and the FastAPI gateway (`:8000`).
FastAPI runs the Alembic migration on startup.

- API: `http://localhost:8000` (`/healthz`, `/auth/register`, `/v1/chat/completions`)
- Admin dashboard: `http://localhost:8000/admin` (log in with `ADMIN_PASSWORD`)

For local-only minimums in `.env`: set `OPENROUTER_API_KEY` to a real key and pick any
non-empty values for the secrets/password. Stop with `Ctrl-C`; wipe all data (including the
Postgres volume) with `docker compose down -v`.

Point a debug build of the app at it (see the app instructions below):

```bash
flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000   # Android emulator
flutter run --dart-define=BACKEND_BASE_URL=http://localhost:8000  # desktop / web / iOS sim
```

## Run in production

The app sends bearer tokens to this backend, so production **must** terminate TLS and the
LLM/admin ports must not be exposed publicly. A typical single-host deployment:

**1. Provision a host** with Docker + Compose, clone the repo, and create `.env` with
**strong, unique** values:

```bash
# generate secrets, e.g.:
openssl rand -hex 32   # APP_TOKEN_SECRET, SESSION_SECRET, LITELLM_MASTER_KEY, ADMIN_PASSWORD
```

Set `POSTGRES_PASSWORD`, `OPENROUTER_API_KEY`, and keep `DEFAULT_BUDGET_USD=5.00` (or your
chosen cap). Never commit `.env`; back it up in a secrets manager.

**2. Keep internal services internal.** The committed `docker-compose.yml` publishes
`4000` (LiteLLM) and `8000` (FastAPI) for convenience. In production, add a
`docker-compose.prod.yml` override that (a) drops the `litellm` port mapping entirely and
(b) binds FastAPI to loopback so only the reverse proxy reaches it:

```yaml
# docker-compose.prod.yml
services:
  litellm:
    ports: []                       # reachable only on the compose network
  fastapi:
    ports:
      - "127.0.0.1:8000:8000"      # proxy connects here; not public
```

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

**3. Put a TLS reverse proxy in front** of FastAPI (port 8000). Example with Caddy
(automatic Let's Encrypt certificates):

```caddyfile
api.yourdomain.com {
    reverse_proxy 127.0.0.1:8000
}
```

Restrict `/admin` further if desired (proxy-level basic auth, IP allow-list, or a VPN) —
it is only password-protected by default.

**4. Persist and back up Postgres.** Data lives in the `pgdata` Docker volume; schedule
regular `pg_dump` backups (or use a managed Postgres and point `DATABASE_URL` at it).

**5. Build the app against the public URL:**

```bash
flutter build apk --release --dart-define=BACKEND_BASE_URL=https://api.yourdomain.com
flutter build ipa --release --dart-define=BACKEND_BASE_URL=https://api.yourdomain.com
```

**Updating:** `git pull && docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build`.
Migrations run automatically on FastAPI startup.

> Note: in this testing phase, devices auto-register with no login. Before a public
> launch, replace the `device_id` auto-registration with real authentication (see "Out of
> scope" in the plan).

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
