"""Behavioral tests for register, proxy auth, and admin budget control."""

import itertools

import pytest

from app import device_service, litellm_client
from app.routers import admin


@pytest.fixture
def mock_litellm(monkeypatch):
    """Stub the LiteLLM admin/chat calls and record what was invoked."""
    calls = {"create_user": 0, "generate_key": 0, "budget_updates": [], "chat": []}
    keys = (f"sk-key-{n}" for n in itertools.count(1))

    async def create_user(user_id, max_budget, models):
        calls["create_user"] += 1

    async def generate_key(user_id):
        calls["generate_key"] += 1
        return next(keys)

    async def get_user_info(user_id):
        return {"user_info": {"max_budget": 5.0, "spend": 0.0}}

    async def update_user_budget(user_id, max_budget):
        calls["budget_updates"].append((user_id, max_budget))

    async def chat_completion(virtual_key, body):
        calls["chat"].append((virtual_key, body))
        return {"choices": [{"message": {"content": "{}"}}]}

    # device_service and routers reference the module attributes, so patch there.
    for name, fn in {
        "create_user": create_user,
        "generate_key": generate_key,
        "get_user_info": get_user_info,
        "update_user_budget": update_user_budget,
        "chat_completion": chat_completion,
    }.items():
        monkeypatch.setattr(litellm_client, name, fn)
    return calls


def test_register_creates_user_then_is_idempotent(client, mock_litellm):
    body = {"device_id": "device-aaaaaaaa"}

    first = client.post("/auth/register", json=body)
    assert first.status_code == 200
    data1 = first.json()["data"]
    assert data1["budget"] == 5.0 and data1["spend"] == 0.0

    second = client.post("/auth/register", json=body)
    assert second.status_code == 200
    data2 = second.json()["data"]

    # Same device → user created exactly once; token rotates on each call.
    assert mock_litellm["create_user"] == 1
    assert mock_litellm["generate_key"] == 2
    assert data1["token"] != data2["token"]


def test_proxy_rejects_missing_or_bad_token(client, mock_litellm):
    no_auth = client.post("/v1/chat/completions", json={"model": "x", "messages": []})
    assert no_auth.status_code == 401
    assert no_auth.json()["error"]["code"] == "UNAUTHORIZED"

    bad = client.post(
        "/v1/chat/completions",
        json={"model": "x", "messages": []},
        headers={"Authorization": "Bearer nope"},
    )
    assert bad.status_code == 401


def test_proxy_forwards_with_devices_virtual_key(client, mock_litellm):
    token = client.post("/auth/register", json={"device_id": "device-bbbbbbbb"}).json()[
        "data"
    ]["token"]

    resp = client.post(
        "/v1/chat/completions",
        json={"model": "google/gemini-2.5-flash-lite", "messages": []},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200
    # Forwarded using the most recently issued virtual key, not the app token.
    assert mock_litellm["chat"][0][0] == "sk-key-1"


def test_admin_budget_update_calls_litellm(client, mock_litellm):
    client.post("/auth/register", json={"device_id": "device-cccccccc"})
    # Resolve the LiteLLM user id created for this device.
    from app.db import SessionLocal
    from app.models import Device

    with SessionLocal() as db:
        user_id = db.query(Device).one().litellm_user_id

    client.post("/admin/login", data={"password": "test-admin-pw"})
    resp = client.post(
        f"/admin/users/{user_id}/budget",
        data={"max_budget": "12.50"},
        follow_redirects=False,
    )
    assert resp.status_code == 303
    assert mock_litellm["budget_updates"] == [(user_id, 12.5)]


def test_admin_requires_login(client):
    resp = client.get("/admin", follow_redirects=False)
    assert resp.status_code == 303
    assert resp.headers["location"] == "/admin/login"
