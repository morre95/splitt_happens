"""Device registration / token refresh."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..db import get_db
from ..device_service import register_device
from ..schemas import RegisterRequest, RegisterResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=RegisterResponse)
async def register(body: RegisterRequest, db: Session = Depends(get_db)) -> RegisterResponse:
    """Auto-register a device on first contact; refresh its token on later calls.

    Idempotent per ``device_id`` — always resolves to the same LiteLLM user.
    """
    data = await register_device(db, body.device_id)
    return RegisterResponse(data=data)
