"""Answer-generation seam for the RAG assistant (ADR-0013).

Every answerer turns a question plus the retrieved chunks into a grounded
:class:`Answer` with source citations. The local default is extractive and
keyless; a hosted LLM is the swap-in. Answerers never invent citations - they
only cite the articles the retrieved chunks came from.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Protocol, runtime_checkable

# Import kept local to the package to avoid a hard dependency cycle at module load.
from ..retrieval import RetrievedChunk


@dataclass(frozen=True)
class Citation:
    slug: str
    title: str


@dataclass
class Answer:
    text: str
    grounded: bool  # False = refusal (nothing relevant in the corpus)
    citations: list[Citation] = field(default_factory=list)
    backend: str = "unknown"


@runtime_checkable
class Answerer(Protocol):
    name: str

    def answer(self, question: str, chunks: list[RetrievedChunk]) -> Answer: ...
