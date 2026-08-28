"""Ingest published Knowledge Hub articles into the pgvector store (RAG-02).

Idempotent and re-runnable: for each published article it rebuilds that
article's chunks + embeddings and replaces them in a single transaction, so
re-running after an edit is safe. Reads `articles` (the source of truth) and
writes `article_chunks` (the derived index), per ADR-0012.

The Postgres client (psycopg, pgvector) is imported lazily inside
``run_ingestion`` so it stays an optional dependency: the pure row-building
logic is unit-tested without a database, and CI installs nothing extra.

Run:  py -m app.services.assistant.ingest
"""

from __future__ import annotations

import logging
from dataclasses import dataclass

from app.core.config import settings

from .chunking import chunk_text
from .embeddings import Embedder, get_embedder

logger = logging.getLogger(__name__)


@dataclass
class ChunkRow:
    article_id: str
    article_slug: str
    chunk_index: int
    content: str
    embedding: list[float]
    embedding_model: str


@dataclass
class IngestReport:
    articles: int
    chunks: int
    embedder: str


def build_chunk_rows(
    article_id: str,
    article_slug: str,
    content: str,
    embedder: Embedder,
) -> list[ChunkRow]:
    """Pure: one article's content -> embedded chunk rows. No database access."""
    chunks = chunk_text(content)
    if not chunks:
        return []
    vectors = embedder.embed(chunks)
    return [
        ChunkRow(
            article_id=article_id,
            article_slug=article_slug,
            chunk_index=index,
            content=chunk,
            embedding=vector,
            embedding_model=embedder.name,
        )
        for index, (chunk, vector) in enumerate(zip(chunks, vectors))
    ]


def run_ingestion(
    dsn: str | None = None,
    embedder: Embedder | None = None,
) -> IngestReport:
    """Rebuild the chunk index for every published article. Requires a Postgres
    with pgvector and the optional client: ``pip install "psycopg[binary]" pgvector``.
    """
    import psycopg  # optional dependency, only needed to actually ingest
    from pgvector.psycopg import register_vector

    dsn = dsn or settings.database_url
    embedder = embedder or get_embedder()
    total_articles = 0
    total_chunks = 0

    with psycopg.connect(dsn) as conn:
        register_vector(conn)
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, slug, content FROM articles "
                "WHERE published = TRUE ORDER BY created_at"
            )
            articles = cur.fetchall()

        for article_id, slug, content in articles:
            rows = build_chunk_rows(str(article_id), slug, content, embedder)
            with conn.cursor() as cur:
                cur.execute(
                    "DELETE FROM article_chunks WHERE article_id = %s",
                    (article_id,),
                )
                for row in rows:
                    cur.execute(
                        "INSERT INTO article_chunks "
                        "(article_id, article_slug, chunk_index, content, "
                        "embedding, embedding_model) "
                        "VALUES (%s, %s, %s, %s, %s, %s)",
                        (
                            row.article_id,
                            row.article_slug,
                            row.chunk_index,
                            row.content,
                            row.embedding,
                            row.embedding_model,
                        ),
                    )
            conn.commit()
            total_articles += 1
            total_chunks += len(rows)

    report = IngestReport(total_articles, total_chunks, embedder.name)
    logger.info(
        "Ingested %d chunks from %d articles using the %s embedder.",
        report.chunks,
        report.articles,
        report.embedder,
    )
    return report


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    report = run_ingestion()
    print(
        f"Ingested {report.chunks} chunks from {report.articles} articles "
        f"(embedder: {report.embedder})."
    )


if __name__ == "__main__":
    main()
