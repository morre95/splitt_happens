"""Async httpx wrapper over the LiteLLM proxy (admin API + chat gateway).

Admin calls use the master key. Chat calls use a per-user virtual key so
LiteLLM enforces that user's budget and records spend against their user record.
"""

from typing import Any

import httpx

from .config import get_settings
from .errors import BudgetExceededError, UpstreamError

_TIMEOUT = httpx.Timeout(30.0)


def _admin_headers() -> dict[str, str]:
    return {"Authorization": f"Bearer {get_settings().litellm_master_key}"}


def _base_url() -> str:
    return get_settings().litellm_base_url.rstrip("/")


async def _post(client: httpx.AsyncClient, path: str, json: dict[str, Any]) -> dict[str, Any]:
    try:
        resp = await client.post(f"{_base_url()}{path}", headers=_admin_headers(), json=json)
    except httpx.RequestError as error:
        raise UpstreamError(f"Could not reach LiteLLM at {path}: {error}") from error
    if resp.status_code >= 400:
        raise UpstreamError(f"LiteLLM {path} failed ({resp.status_code}): {resp.text[:300]}")
    return resp.json()


async def _get(client: httpx.AsyncClient, path: str, params: dict[str, Any]) -> dict[str, Any]:
    try:
        resp = await client.get(f"{_base_url()}{path}", headers=_admin_headers(), params=params)
    except httpx.RequestError as error:
        raise UpstreamError(f"Could not reach LiteLLM at {path}: {error}") from error
    if resp.status_code >= 400:
        raise UpstreamError(f"LiteLLM {path} failed ({resp.status_code}): {resp.text[:300]}")
    return resp.json()


async def create_user(user_id: str, max_budget: float, models: list[str]) -> None:
    """Create a LiteLLM internal user with a per-user budget."""
    async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
        await _post(
            client,
            "/user/new",
            {
                "user_id": user_id,
                "user_role": "internal_user",
                "max_budget": max_budget,
                "models": models,
            },
        )


async def generate_key(user_id: str) -> str:
    """Generate a fresh virtual key bound to an existing user; return the key."""
    async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
        data = await _post(client, "/key/generate", {"user_id": user_id})
    key = data.get("key")
    if not key:
        raise UpstreamError("LiteLLM /key/generate returned no key.")
    return key


async def get_user_info(user_id: str) -> dict[str, Any]:
    """Return the raw LiteLLM user info (includes spend and max_budget)."""
    async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
        return await _get(client, "/user/info", {"user_id": user_id})


async def update_user_budget(user_id: str, max_budget: float) -> None:
    """Change a user's max budget."""
    async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
        await _post(client, "/user/update", {"user_id": user_id, "max_budget": max_budget})


async def reset_user_spend(user_id: str) -> None:
    """Reset a user's accumulated spend to zero via the admin API.

    NOTE: spend-reset support is LiteLLM-version-dependent — confirmed against
    the pinned image. ``/user/update`` accepts ``spend`` on current stable.
    """
    async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
        await _post(client, "/user/update", {"user_id": user_id, "spend": 0})


async def get_spend_logs(user_id: str) -> list[dict[str, Any]]:
    """Return recent spend log rows for a user (activity feed)."""
    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
            resp = await client.get(
                f"{_base_url()}/spend/logs",
                headers=_admin_headers(),
                params={"user_id": user_id},
            )
    except httpx.RequestError:
        return []
    if resp.status_code >= 400:
        # Activity log is best-effort; don't fail the whole dashboard for it.
        return []
    data = resp.json()
    return data if isinstance(data, list) else data.get("data", [])


async def chat_completion(virtual_key: str, body: dict[str, Any]) -> dict[str, Any]:
    """Forward an OpenAI-format chat request using a user's virtual key.

    Maps LiteLLM's budget-exceeded response to a clean BUDGET_EXCEEDED error.
    """
    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
            resp = await client.post(
                f"{_base_url()}/chat/completions",
                headers={"Authorization": f"Bearer {virtual_key}"},
                json=body,
            )
    except httpx.RequestError as error:
        raise UpstreamError(f"Could not reach the LLM service: {error}") from error
    if resp.status_code == 200:
        return resp.json()

    text = resp.text.lower()
    if resp.status_code in (400, 429) and "budget" in text:
        raise BudgetExceededError(
            "Your usage budget has been reached. Ask an admin to increase it."
        )
    raise UpstreamError(f"LLM request failed ({resp.status_code}): {resp.text[:300]}")
