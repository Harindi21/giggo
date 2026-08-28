"""sentence-transformers embedder — the local semantic default (ADR-0013).

Optional dependency (``pip install sentence-transformers``). Imported lazily so
the service falls back to the hashed embedder when it — or torch — isn't
installed, keeping CI light. Vectors are L2-normalised to match the other
backends.
"""

from __future__ import annotations


class SentenceTransformerEmbedder:
    name = "sentence-transformers"

    def __init__(self, model_name: str) -> None:
        from sentence_transformers import SentenceTransformer  # lazy, optional

        self._model = SentenceTransformer(model_name)
        self.dim = int(self._model.get_sentence_embedding_dimension())

    def embed(self, texts: list[str]) -> list[list[float]]:
        vectors = self._model.encode(
            list(texts),
            normalize_embeddings=True,
            convert_to_numpy=True,
        )
        return [[float(x) for x in row] for row in vectors]
