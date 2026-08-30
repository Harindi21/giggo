"""Versioned prompts and answer templates for the RAG assistant (RAG-17).

Kept in one place so a change to how the assistant speaks - or to what it says
when it refuses - is a small, reviewable diff rather than an edit buried in
logic. The numeric tuning knobs live beside the code that uses them:
``retrieval_top_k`` in ``app/core/config.py`` and ``DEFAULT_MIN_SCORE`` /
``DEFAULT_MIN_OVERLAP`` in ``pipeline.py``.
"""

from __future__ import annotations

# Prepended to an extractive answer built from the retrieved chunks.
ANSWER_PREAMBLE = "Based on the GIGGO Knowledge Hub:"

# Shown when nothing relevant is found, the question is off-topic, or it looks
# like a prompt-injection attempt.
REFUSAL_MESSAGE = (
    "I don't have anything about that in the GIGGO Knowledge Hub yet. "
    "Try rephrasing, or ask about bookings, payments, safety or getting verified."
)
