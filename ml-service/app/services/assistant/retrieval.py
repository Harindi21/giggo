"""Retrieve the most relevant article chunks for a question (RAG-03).

Embeds the question with the same embedder used at ingestion and asks pgvector
for the nearest chunks by cosine similarity, joining back to the source article
for citation metadata. The Postgres client is imported lazily so it stays an
optional dependency (ADR-0012); the endpoint and pipeline are unit-tested with a
fake retriever, so no database is needed in CI.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol, runtime_checkable

from app.core.config import settings

from .embeddings import Embedder, get_embedder


@dataclass
class RetrievedChunk:
    content: str
    article_slug: str
    article_title: str
    score: float  # cosine similarity in [-1, 1]; higher is closer


@runtime_checkable
class Retriever(Protocol):
    def retrieve(self, question: str, top_k: int) -> list[RetrievedChunk]: ...


class PgVectorRetriever:
    """pgvector-backed retriever over the ``article_chunks`` index."""

    def __init__(self, dsn: str | None = None, embedder: Embedder | None = None) -> None:
        self._dsn = dsn or settings.database_url
        self._embedder = embedder or get_embedder()

    def retrieve(self, question: str, top_k: int) -> list[RetrievedChunk]:
        import psycopg  # optional dependency, only needed for real retrieval
        from pgvector.psycopg import register_vector

        query_vec = self._embedder.embed([question])[0]
        with psycopg.connect(self._dsn) as conn:
            register_vector(conn)
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT ac.content, ac.article_slug, a.title, "
                    "1 - (ac.embedding <=> %s) AS score "
                    "FROM article_chunks ac "
                    "JOIN articles a ON a.id = ac.article_id "
                    "ORDER BY ac.embedding <=> %s "
                    "LIMIT %s",
                    (query_vec, query_vec, top_k),
                )
                rows = cur.fetchall()
        return [
            RetrievedChunk(
                content=content,
                article_slug=slug,
                article_title=title,
                score=float(score),
            )
            for content, slug, title, score in rows
        ]


_retriever: Retriever | None = None


def get_retriever() -> Retriever:
    global _retriever
    if _retriever is None:
        _retriever = PgVectorRetriever()
    return _retriever
