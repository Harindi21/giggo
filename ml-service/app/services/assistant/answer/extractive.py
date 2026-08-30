"""Keyless local answerer: grounded and extractive (ADR-0013 default).

Builds the answer straight from the top retrieved chunks and cites the articles
they came from - no LLM, no key, no network. It cannot hallucinate because it
never generates free text beyond a short grounding preamble; the trade-off is
lower fluency than a hosted model, which the Phase-2 eval measures. A hosted
instruct model is the swap-in behind ``assistant_backend``.
"""

from __future__ import annotations

from ..prompts import ANSWER_PREAMBLE, REFUSAL_MESSAGE
from ..retrieval import RetrievedChunk
from .base import Answer, Citation


class LocalExtractiveAnswerer:
    name = "local-extractive"

    def __init__(self, max_chunks: int = 2) -> None:
        self.max_chunks = max_chunks

    def answer(self, question: str, chunks: list[RetrievedChunk]) -> Answer:
        if not chunks:
            return Answer(text=REFUSAL_MESSAGE, grounded=False, backend=self.name)

        used = chunks[: self.max_chunks]
        body = " ".join(c.content.strip() for c in used if c.content.strip())

        # De-duplicate citations by slug while preserving retrieval order.
        titles_by_slug: dict[str, str] = {}
        for c in used:
            titles_by_slug.setdefault(c.article_slug, c.article_title)
        citations = [Citation(slug=s, title=t) for s, t in titles_by_slug.items()]

        return Answer(
            text=f"{ANSWER_PREAMBLE} {body}",
            grounded=True,
            citations=citations,
            backend=self.name,
        )
