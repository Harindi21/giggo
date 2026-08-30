# Reproducible ML-service tasks (RAG-18).
#
# The embedding model is pinned via embedding_model in app/core/config.py
# (sentence-transformers/all-MiniLM-L6-v2), so rebuilding the index is
# deterministic for a given corpus + model. Every target is a single command;
# the raw commands also work without `make` (see each recipe).

.PHONY: install install-rag ingest eval test serve

# Base deps only (keyless: hashed embedder, no torch/pgvector).
install:
	pip install -r requirements.txt

# Optional heavy backends for real semantic RAG (embeddings + Postgres client).
install-rag:
	pip install "psycopg[binary]" pgvector sentence-transformers

# Rebuild the pgvector index from published articles (idempotent, re-runnable).
ingest:
	python -m app.services.assistant.ingest

# Assistant quality gate: retrieval / citation / groundedness / refusal.
eval:
	python -m evaluation.assistant_eval

# Full test suite.
test:
	python -m pytest -q

# Run the API locally (dashboard at /api/v1/assistant/dashboard).
serve:
	python -m uvicorn app.main:app --port 8000 --reload
