"""Split article text into overlapping chunks for retrieval (RAG-01).

Pure and deterministic — no I/O and no model — so it is trivially testable and
the ingestion job (RAG-02) reuses it. Chunks overlap so a fact that straddles a
boundary still lands wholly inside at least one chunk. Boundaries snap to
whitespace so words are never split mid-token.
"""

from __future__ import annotations

DEFAULT_CHUNK_SIZE = 800
DEFAULT_OVERLAP = 150


def chunk_text(
    text: str,
    *,
    chunk_size: int = DEFAULT_CHUNK_SIZE,
    overlap: int = DEFAULT_OVERLAP,
) -> list[str]:
    """Return overlapping ``chunk_size``-ish character windows of ``text``.

    Whitespace is normalised first. Empty/blank text yields an empty list; text
    shorter than ``chunk_size`` yields a single chunk.
    """
    if chunk_size <= 0:
        raise ValueError("chunk_size must be positive")
    if overlap < 0 or overlap >= chunk_size:
        raise ValueError("overlap must be in [0, chunk_size)")

    normalized = " ".join((text or "").split())
    if not normalized:
        return []
    if len(normalized) <= chunk_size:
        return [normalized]

    chunks: list[str] = []
    start = 0
    n = len(normalized)
    while start < n:
        end = min(start + chunk_size, n)
        # Snap the end back to the last space so we don't split a word.
        if end < n:
            space = normalized.rfind(" ", start, end)
            if space > start:
                end = space
        chunk = normalized[start:end].strip()
        if chunk:
            chunks.append(chunk)
        if end >= n:
            break
        start = max(end - overlap, start + 1)
    return chunks
