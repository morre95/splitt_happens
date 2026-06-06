"""Opaque app-token minting/hashing and admin session helpers."""

import hashlib
import hmac
import secrets

from itsdangerous import BadSignature, URLSafeSerializer

from .config import get_settings

_ADMIN_SESSION_SALT = "admin-session"


def mint_app_token() -> str:
    """Return a fresh, URL-safe opaque token to hand to a client."""
    return secrets.token_urlsafe(32)


def hash_app_token(token: str) -> str:
    """Deterministically hash a token for storage/lookup (HMAC-SHA256).

    Tokens are looked up by hash, so the hash must be stable for a given token —
    hence HMAC keyed by ``APP_TOKEN_SECRET`` rather than a random salt.
    """
    secret = get_settings().app_token_secret.encode()
    return hmac.new(secret, token.encode(), hashlib.sha256).hexdigest()


def verify_admin_password(candidate: str) -> bool:
    """Constant-time comparison against the configured admin password."""
    return hmac.compare_digest(candidate, get_settings().admin_password)


def _serializer() -> URLSafeSerializer:
    return URLSafeSerializer(get_settings().session_secret, salt=_ADMIN_SESSION_SALT)


def create_admin_session() -> str:
    """Return a signed cookie value marking an authenticated admin session."""
    return _serializer().dumps({"admin": True})


def is_valid_admin_session(cookie: str | None) -> bool:
    """Validate a signed admin session cookie."""
    if not cookie:
        return False
    try:
        data = _serializer().loads(cookie)
    except BadSignature:
        return False
    return bool(data.get("admin"))
