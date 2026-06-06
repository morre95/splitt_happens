"""Authenticated, non-streaming chat-completions proxy.

The client authenticates with our opaque app token; we forward the request to
LiteLLM using the device's server-side virtual key, so the client never holds a
spendable credential.
"""

from typing import Any

from fastapi import APIRouter, Depends, Header, Request
from sqlalchemy.orm import Session

from .. import litellm_client
from ..db import get_db
from ..device_service import device_for_token
from ..errors import UnauthorizedError

router = APIRouter(prefix="/v1", tags=["proxy"])


def _bearer_token(authorization: str | None) -> str:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise UnauthorizedError("Missing bearer token.")
    return authorization[7:].strip()


@router.post("/chat/completions")
async def chat_completions(
    request: Request,
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> dict[str, Any]:
    token = _bearer_token(authorization)
    device = device_for_token(db, token)
    body = await request.json()
    return await litellm_client.chat_completion(device.litellm_key, body)
