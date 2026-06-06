"""Device registration / token-refresh business logic.

The ``device_id`` is the durable identity: first contact creates a LiteLLM user
with the default budget; every contact (re)issues a fresh virtual key and app
token for the *same* user, so spend persists across token refreshes.
"""

import uuid

from sqlalchemy.orm import Session

from . import litellm_client
from .config import get_settings
from .errors import UnauthorizedError
from .models import Device
from .schemas import RegisterData
from .security import hash_app_token, mint_app_token

# Models this app exposes (mirrors the LiteLLM config aliases).
_ALLOWED_MODELS = [
    "google/gemini-2.5-flash-lite",
    "openai/gpt-5.4-nano",
    "anthropic/claude-haiku-4-5",
]


async def register_device(db: Session, device_id: str) -> RegisterData:
    """Find-or-create the device, rotate its key+token, return current budget/spend."""
    settings = get_settings()
    device = db.query(Device).filter(Device.device_id == device_id).one_or_none()

    if device is None:
        litellm_user_id = f"dev_{uuid.uuid4().hex}"
        await litellm_client.create_user(
            litellm_user_id, settings.default_budget_usd, _ALLOWED_MODELS
        )
        key = await litellm_client.generate_key(litellm_user_id)
        device = Device(
            device_id=device_id,
            litellm_user_id=litellm_user_id,
            litellm_key=key,
            app_token_hash="",  # set below
        )
        db.add(device)
    else:
        # Returning device: rotate the underlying virtual key (same user).
        device.litellm_key = await litellm_client.generate_key(device.litellm_user_id)

    token = mint_app_token()
    device.app_token_hash = hash_app_token(token)
    db.commit()
    db.refresh(device)

    info = await litellm_client.get_user_info(device.litellm_user_id)
    budget, spend = _budget_and_spend(info, settings.default_budget_usd)
    return RegisterData(token=token, budget=budget, spend=spend)


def device_for_token(db: Session, token: str) -> Device:
    """Resolve a device by its opaque app token, or raise UNAUTHORIZED."""
    device = (
        db.query(Device)
        .filter(Device.app_token_hash == hash_app_token(token))
        .one_or_none()
    )
    if device is None:
        raise UnauthorizedError("Invalid or expired token.")
    return device


def _budget_and_spend(info: dict, default_budget: float) -> tuple[float, float]:
    """Pull budget/spend out of LiteLLM's /user/info payload, tolerant of shape."""
    user = info.get("user_info") or info
    max_budget = user.get("max_budget")
    spend = user.get("spend", 0.0) or 0.0
    return (
        float(max_budget) if max_budget is not None else default_budget,
        float(spend),
    )
