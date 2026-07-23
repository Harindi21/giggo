from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "GIGGO ML Service"
    environment: str = "local"
    api_key: str = "local-dev-key"


settings = Settings()