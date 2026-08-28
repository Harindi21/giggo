-- Retrieval store for the Knowledge Hub assistant (RAG-02, ADR-0012).
-- A pgvector-backed chunk index over published articles. This is derived,
-- rebuildable state owned by the ML ingestion job; `articles` stays the source
-- of truth. Schema is migration-only (ADR-0006), so the table + extension are
-- created here even though the Python ML service is what reads/writes it.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE article_chunks (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id       UUID NOT NULL REFERENCES articles (id) ON DELETE CASCADE,
    article_slug     VARCHAR(160) NOT NULL,
    chunk_index      INTEGER NOT NULL,
    content          TEXT NOT NULL,
    embedding        vector(384) NOT NULL,
    embedding_model  VARCHAR(120) NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (article_id, chunk_index)
);

CREATE INDEX idx_article_chunks_article ON article_chunks (article_id);

-- Approximate nearest-neighbour index for cosine similarity (pgvector HNSW).
CREATE INDEX idx_article_chunks_embedding
    ON article_chunks USING hnsw (embedding vector_cosine_ops);
