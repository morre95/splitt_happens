"""Database engine and session management."""

from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from .config import get_settings


def _sqlalchemy_url(raw_url: str) -> str:
    """Pin the psycopg (v3) driver.

    The shared ``DATABASE_URL`` uses the bare ``postgresql://`` scheme for
    LiteLLM. SQLAlchemy would default that to psycopg2, which we don't install,
    so rewrite it to the psycopg v3 dialect.
    """
    if raw_url.startswith("postgresql://"):
        return raw_url.replace("postgresql://", "postgresql+psycopg://", 1)
    return raw_url


_settings = get_settings()
engine = create_engine(_sqlalchemy_url(_settings.database_url), pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


class Base(DeclarativeBase):
    """Declarative base for all ORM models."""


def get_db() -> Iterator[Session]:
    """FastAPI dependency that yields a session and always closes it."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
