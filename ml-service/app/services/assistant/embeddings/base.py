"""Embedding seam for the RAG assistant (ADR-0013).

Every embedder maps texts to **fixed-dimension, L2-normalised** vectors, so
cosine similarity reduces to a dot product and vectors are comparable across
backends. The dimension is fixed at ``EMBED_DIM`` — it must match the pgvector
column added in the ingestion migration (RAG-02).
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

# all-MiniLM-L6-v2 dimensionality; the pgvector column is vector(EMBED_DIM).
EMBED_DIM = 384


@runtime_checkable
class Embedder(Protocol):
    name: str
    dim: int

    def embed(self, texts: list[str]) -> list[list[float]]:
        """Return one ``dim``-length, L2-normalised vector per input text."""
        ...
