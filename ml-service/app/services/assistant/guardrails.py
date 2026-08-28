"""Guardrails for the RAG assistant (RAG-11..RAG-13).

Three defences that work even with the keyless hashed embedder:

- Grounded refusal / scope limiting: a **content-word overlap gate**. Cosine
  retrieval alone can rank an off-topic question against the corpus because common
  stop-words overlap, so we additionally require the top chunk to share real
  content words with the question. If it does not, we refuse. This is what makes
  "what is the capital of France" refuse instead of answering.
- Prompt-injection defence: detect and refuse questions that try to override
  instructions ("ignore previous instructions", "you are now ...") rather than
  ask about the Knowledge Hub. When a hosted LLM backend is added, retrieved
  article text is likewise treated as untrusted data, never as instructions.
"""

from __future__ import annotations

import re

from .retrieval import RetrievedChunk

# Small English stop-word set; "content words" are everything else. Kept local
# and dependency-free. Question words (how/what/why...) are stop-words so an
# off-topic question's content words are its topical nouns, not its scaffolding.
_STOPWORDS = frozenset(
    {
        "a", "about", "after", "an", "and", "any", "are", "as", "at", "be",
        "before", "but", "by", "can", "could", "do", "does", "for", "from",
        "get", "give", "how", "i", "if", "in", "into", "is", "it", "its",
        "just", "me", "my", "no", "not", "of", "on", "or", "over", "should",
        "so", "some", "tell", "that", "the", "their", "them", "then", "there",
        "they", "this", "to", "up", "use", "want", "was", "we", "what", "when",
        "where", "which", "who", "why", "will", "with", "would", "you", "your",
    }
)

_WORD = re.compile(r"[a-z0-9]+")

_INJECTION_PATTERNS = [
    re.compile(pattern)
    for pattern in (
        r"ignore\s+(all\s+|the\s+|your\s+)?(previous|prior|above|earlier)",
        r"disregard\s+(all\s+|the\s+|your\s+)?(previous|prior|above)",
        r"forget\s+(all\s+|your\s+|the\s+)?(previous|prior|earlier)",
        r"you\s+are\s+now\b",
        r"act\s+as\b",
        r"pretend\s+to\s+be\b",
        r"system\s+prompt",
        r"reveal\s+(your\s+)?(system\s+)?(prompt|instructions)",
        r"override\s+(your\s+)?(instructions|rules)",
        r"jailbreak",
    )
]


def content_words(text: str) -> set[str]:
    return {
        token
        for token in _WORD.findall((text or "").lower())
        if len(token) > 1 and token not in _STOPWORDS
    }


def content_overlap(question: str, text: str) -> float:
    """Fraction of the question's content words that also appear in ``text``."""
    question_words = content_words(question)
    if not question_words:
        return 0.0
    return len(question_words & content_words(text)) / len(question_words)


def looks_like_injection(text: str) -> bool:
    low = (text or "").lower()
    return any(pattern.search(low) for pattern in _INJECTION_PATTERNS)


def is_on_topic(
    question: str,
    chunks: list[RetrievedChunk],
    min_overlap: float,
) -> bool:
    """True if any retrieved chunk shares enough content words with the question."""
    if not chunks:
        return False
    best = max(content_overlap(question, c.content) for c in chunks)
    return best >= min_overlap
