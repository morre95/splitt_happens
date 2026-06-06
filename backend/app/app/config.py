"""Environment-driven application settings (single source of truth)."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime configuration loaded from environment variables."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Database
    database_url: str

    # LiteLLM proxy
    litellm_base_url: str
    litellm_master_key: str

    # App auth / admin
    app_token_secret: str
    admin_password: str
    session_secret: str

    # Budgets
    default_budget_usd: float = 5.00


@lru_cache
def get_settings() -> Settings:
    """Return cached settings so the env is parsed once per process."""
    return Settings()  # type: ignore[call-arg]
