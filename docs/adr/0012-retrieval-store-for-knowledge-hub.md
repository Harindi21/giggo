# ADR-0012: Retrieval store for the Knowledge Hub (pgvector)

- **Status:** Accepted
- **Date:** 2026-08-28

## Context
The Knowledge Hub (P9) holds published articles (`articles`: `title`, `category`,
`content`, `slug`). We want a retrieval-augmented assistant that answers a user's
question **using only those articles** and cites its sources. That needs semantic
retrieval: embed the article text, embed the question, and find the nearest chunks.

This collides with [ADR-0003](0003-stateless-ml-service.md): the ML service is
stateless and has no database. RAG is inherently stateful — it needs a durable index
of embedded chunks to search. So a decision is required: *where does that index live,
and does the ML service get to own state?*

Constraints we already have: PostgreSQL 17 runs in `docker-compose.yml`; the schema is
migration-only ([ADR-0006](0006-flyway-migrations-and-testcontainers.md)); and the
seam philosophy ([ADR-0001](0001-integration-seams-with-stub-defaults.md)) says
default to keyless, free, local components.

## Decision
Introduce a vector store using the **pgvector** extension on the **existing Postgres**
— no new infrastructure. Article `content` is split into overlapping chunks and stored
with their embeddings and a reference back to the source article `slug` in a new
`article_chunks` table, added via a Flyway migration (schema stays migration-only).

The **ML service owns the RAG pipeline** — ingestion, embedding, retrieval and the
`/assistant/ask` endpoint — and therefore gains a **scoped Postgres connection**. This
is a **deliberate, bounded exception to ADR-0003**, justified because the RAG index is
**derived, reproducible state, not a second source of truth**: the `articles` table
remains the system of record, and the index is a materialized projection that can be
dropped and rebuilt at any time by re-running the idempotent ingestion job. The ML
service reads `articles` and owns `article_chunks`; it does not become authoritative
for any business data.

## Alternatives considered
- **A dedicated vector database** (Pinecone / Weaviate / Qdrant) — new infrastructure,
  another thing to run, secure and pay for, for a corpus of dozens–hundreds of
  articles. pgvector on the Postgres we already operate is enough at this scale.
- **In-process, in-memory index** (e.g. FAISS built at boot) — not durable, rebuilt on
  every start, and not shared across replicas; fine for a toy, wrong for a service.
- **Keep the ML service strictly stateless** and do vector search in the Java backend —
  splits the RAG pipeline across two services and two languages, duplicating the
  embedding/retrieval logic away from the Python ML ecosystem where it belongs.

## Consequences
- No new infrastructure: one Postgres to run, back up and operate; pgvector is a single
  extension + migration.
- The index must be kept in sync with articles — handled by an **idempotent,
  re-runnable ingestion job** (RAG-01), a reproducible index build (RAG-18), not live
  triggers. Retrieval reads a possibly-stale index between rebuilds; acceptable for a
  guides corpus that changes rarely.
- ADR-0003 now has one explicit carve-out: the ML service holds a read-mostly RAG index.
  Everything else it does stays stateless. We revisit and move to a dedicated vector DB
  only if corpus size or query latency outgrows pgvector.
