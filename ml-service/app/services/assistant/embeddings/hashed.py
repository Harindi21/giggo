"""Deterministic, dependency-free fallback embedder.

Signed feature-hashing over word tokens, projected into ``EMBED_DIM`` and
L2-normalised. It is **not** semantically strong — it exists so the assistant
runs and CI stays green when sentence-transformers isn't installed (mirroring the
sentiment lexicon fallback). Real semantic quality comes from the
sentence-transformer backend; the Phase-2 eval measures the gap between them.
"""

from __future__ import annotations

import hashlib
import math
import re

from .base import EMBED_DIM

_TOKEN = re.compile(r"[a-z0-9]+")


class HashedEmbedder:
    name = "hashed"

    def __init__(self, dim: int = EMBED_DIM) -> None:
        self.dim = dim

    def embed(self, texts: list[str]) -> list[list[float]]:
        return [self._embed_one(t) for t in texts]

    def _embed_one(self, text: str) -> list[float]:
        vec = [0.0] * self.dim
        for token in _TOKEN.findall((text or "").lower()):
            digest = hashlib.blake2b(token.encode(), digest_size=8).digest()
            h = int.from_bytes(digest, "big")
            idx = h % self.dim
            sign = 1.0 if (h >> 8) & 1 else -1.0
            vec[idx] += sign
        norm = math.sqrt(sum(v * v for v in vec))
        if norm == 0.0:
            return vec  # all-zero for empty/tokenless text — safe, no NaNs
        return [v / norm for v in vec]
