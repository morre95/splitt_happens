"""create devices table

Revision ID: 0001
Revises:
Create Date: 2026-06-06
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "devices",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("device_id", sa.String(), nullable=False),
        sa.Column("litellm_user_id", sa.String(), nullable=False),
        sa.Column("litellm_key", sa.String(), nullable=False),
        sa.Column("app_token_hash", sa.String(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.UniqueConstraint("device_id", name="uq_devices_device_id"),
        sa.UniqueConstraint("litellm_user_id", name="uq_devices_litellm_user_id"),
        sa.UniqueConstraint("app_token_hash", name="uq_devices_app_token_hash"),
    )
    op.create_index("ix_devices_device_id", "devices", ["device_id"])
    op.create_index("ix_devices_app_token_hash", "devices", ["app_token_hash"])


def downgrade() -> None:
    op.drop_index("ix_devices_app_token_hash", table_name="devices")
    op.drop_index("ix_devices_device_id", table_name="devices")
    op.drop_table("devices")
