"""Tie retrieval and answer generation into one grounded answer (RAG-04).

Retrieves the top-k chunks, drops any below a minimum similarity so unrelated
questions are refused rather than answered from weak matches (a basic grounded
guardrail; Phase 3 hardens it), then hands the survivors to the answerer. Pure
given a retriever and an answerer, so it is unit-tested with fakes - no database.
"""

from __future__ import annotations

from app.core.config import settings

from .answer import Answer, Answerer, get_answerer
from .retrieval import Retriever, get_retriever

# Minimum cosine similarity for a chunk to count as relevant. Deliberately low
# because the keyless hashed fallback embedder produces modest similarities; the
# Phase-2 eval tunes this per embedding backend.
DEFAULT_MIN_SCORE = 0.1


def answer_question(
    question: str,
    *,
    retriever: Retriever | None = None,
    answerer: Answerer | None = None,
    top_k: int | None = None,
    min_score: float = DEFAULT_MIN_SCORE,
) -> tuple[Answer, int]:
    """Return the grounded answer and how many chunks were retrieved."""
    retriever = retriever or get_retriever()
    answerer = answerer or get_answerer()
    top_k = top_k or settings.retrieval_top_k

    retrieved = retriever.retrieve(question, top_k)
    relevant = [c for c in retrieved if c.score >= min_score]
    return answerer.answer(question, relevant), len(retrieved)
