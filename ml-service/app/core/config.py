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

    # --- RAG assistant observability + cost (Phase 4) ---
    # Estimated hosted-LLM price per 1000 tokens (USD); 0 for the keyless local
    # backend, so day-to-day usage is free and the dashboard shows zero cost.
    assistant_cost_per_1k_input: float = 0.0
    assistant_cost_per_1k_output: float = 0.0
    # Alert thresholds (RAG-16): an alert fires when a rolling metric crosses these.
    alert_p95_latency_ms: float = 1500.0
    alert_avg_cost_usd: float = 0.05
    alert_refusal_rate: float = 0.60


settings = Settings()