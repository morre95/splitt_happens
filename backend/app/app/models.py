"""ORM models. Each table is defined exactly once, here."""

import uuid
from datetime import datetime

from sqlalchemy import DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column

from .db import Base


class Device(Base):
    """Maps a stable client ``device_id`` to its LiteLLM user and current token.

    During the testing phase the ``device_id`` is the durable identity: the app
    token rotates, but the same device always resolves to the same LiteLLM user
    so spend accumulates continuously.
    """

    __tablename__ = "devices"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    device_id: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    litellm_user_id: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    litellm_key: Mapped[str] = mapped_column(String, nullable=False)
    app_token_hash: Mapped[str] = mapped_column(
        String, unique=True, nullable=False, index=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
