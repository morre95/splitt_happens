"""Pydantic request/response models."""

from typing import Any

from pydantic import BaseModel, Field


class RegisterRequest(BaseModel):
    """Body for POST /auth/register."""

    device_id: str = Field(min_length=8, max_length=128)


class RegisterData(BaseModel):
    """Payload returned to a client after register/refresh."""

    token: str
    budget: float
    spend: float


class RegisterResponse(BaseModel):
    """Success envelope for register."""

    success: bool = True
    data: RegisterData


# Chat proxy bodies are passthrough OpenAI-format dicts; we don't constrain them
# beyond requiring an object, so the proxy stays a thin forwarder.
ChatCompletionRequest = dict[str, Any]
