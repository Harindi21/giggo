"""Select the embedding backend from config, with a safe fallback (ADR-0013).

Default is the local sentence-transformer model; if it (or torch) isn't
installed, or the model's dimension doesn't match ``EMBED_DIM``, we fall back to
the deterministic hashed embedder and log it — exactly like the sentiment
service falls back from RoBERTa to VADER.
"""

from __future__ import annotations

import logging

from app.core.config import settings

from .base import EMBED_DIM, Embedder
from .hashed import HashedEmbedder

logger = logging.getLogger(__name__)

_SENTENCE_TRANSFORMER_BACKENDS = {"local", "sentence-transformers", "sstransformers"}


def build_embedder(backend: str | None = None) -> Embedder:
    backend = (backend or settings.embedding_backend or "local").lower()

    if backend in _SENTENCE_TRANSFORMER_BACKENDS:
        try:
            from .sentence_transformer import SentenceTransformerEmbedder

            embedder = SentenceTransformerEmbedder(settings.embedding_model)
            if embedder.dim != EMBED_DIM:
                logger.warning(
                    "Embedding model %s has dim %d, expected %d; using hashed fallback.",
                    settings.embedding_model,
                    embedder.dim,
                    EMBED_DIM,
                )
                return HashedEmbedder()
            return embedder
        except Exception as exc:  # sentence-transformers/torch missing, model load error
            logger.warning(
                "sentence-transformers unavailable (%s); using hashed fallback embedder.",
                exc,
            )
            return HashedEmbedder()

    if backend == "hashed":
        return HashedEmbedder()

    logger.warning("Unknown embedding backend %r; using hashed fallback.", backend)
    return HashedEmbedder()


_embedder: Embedder | None = None


def get_embedder() -> Embedder:
    global _embedder
    if _embedder is None:
        _embedder = build_embedder()
    return _embedder
