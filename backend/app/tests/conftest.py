"""Test fixtures: SQLite-backed app with the LiteLLM client mocked out."""

import os
import tempfile

# Configure env BEFORE importing app modules (engine/settings read it at import).
_db_fd, _db_path = tempfile.mkstemp(suffix=".db")
os.environ.update(
    {
        "DATABASE_URL": f"sqlite:///{_db_path}",
        "LITELLM_BASE_URL": "http://litellm.test",
        "LITELLM_MASTER_KEY": "sk-test-master",
        "APP_TOKEN_SECRET": "test-token-secret",
        "ADMIN_PASSWORD": "test-admin-pw",
        "SESSION_SECRET": "test-session-secret",
        "DEFAULT_BUDGET_USD": "5.00",
    }
)

import pytest
from fastapi.testclient import TestClient

from app.db import Base, engine
from app.main import app


@pytest.fixture(autouse=True)
def _fresh_db():
    """Recreate tables before each test for isolation."""
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)
