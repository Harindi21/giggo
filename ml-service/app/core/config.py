from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "GIGGO ML Service"
    environment: str = "local"
    api_key: str = "local-dev-key"

    # Sentiment backend: "lexicon" (VADER, default) or "transformer" (RoBERTa, future).
    sentiment_backend: str = "lexicon"

    # Recommender backend: "hybrid" (pure-Python, default) or "lightfm" (future).
    recommender_backend: str = "hybrid"


settings = Settings()