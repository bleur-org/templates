from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

__all__ = ("settings",)


class Settings(BaseSettings):
    DEBUG: bool = Field(default=False, frozen=True)

    model_config = SettingsConfigDict(env_file=".env")


settings = Settings()
