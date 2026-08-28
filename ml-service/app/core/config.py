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

    # --- RAG assistant (Knowledge Hub) — keyless local defaults, hosted swap-in.
    # See ADR-0012 (retrieval store) and ADR-0013 (LLM provider seam).
    # Answer generation: "local" (grounded/extractive default) or a hosted LLM.
    assistant_backend: str = "local"
    # Embeddings: "local" (sentence-transformers default) or a hosted embeddings API.
    embedding_backend: str = "local"
    # Local sentence-embedding model used when embedding_backend == "local".
    embedding_model: str = "sentence-transformers/all-MiniLM-L6-v2"
    # Hosted model id, used when assistant_backend names a hosted provider.
    # The API key itself comes from the environment, never from code.
    assistant_model: str = ""
    # Retrieval: number of chunks returned per question (top-k).
    retrieval_top_k: int = 4

    # Postgres DSN for the RAG retrieval store (ADR-0012, scoped read/write access).
    # Defaults to the local dev database; in prod set DATABASE_URL in the environment.
    database_url: str = "postgresql://giggo:giggo_local_dev@127.0.0.1:5433/giggo"


settings = Settings()