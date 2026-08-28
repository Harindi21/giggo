import math

from app.services.assistant.embeddings.base import EMBED_DIM
from app.services.assistant.embeddings.hashed import HashedEmbedder
from app.services.assistant.embeddings.service import build_embedder


def _dot(a, b):
    return sum(x * y for x, y in zip(a, b))


def test_hashed_embedder_is_deterministic_and_normalised():
    e = HashedEmbedder()
    a = e.embed(["fix a leaking pipe at home"])[0]
    b = e.embed(["fix a leaking pipe at home"])[0]
    assert a == b
    assert len(a) == EMBED_DIM
    assert math.isclose(math.sqrt(sum(x * x for x in a)), 1.0, rel_tol=1e-6)


def test_hashed_embedder_handles_empty_text():
    v = HashedEmbedder().embed([""])[0]
    assert len(v) == EMBED_DIM
    assert all(x == 0.0 for x in v)  # zero vector, no crash / NaN


def test_related_text_scores_higher_than_unrelated():
    q, near, far = HashedEmbedder().embed(
        [
            "how to fix a leaking pipe",
            "steps to fix a leaking pipe at home",
            "best mobile wallet to get paid instantly",
        ]
    )
    assert _dot(q, near) > _dot(q, far)


def test_service_falls_back_to_hashed_without_sentence_transformers():
    # In CI sentence-transformers isn't installed, so 'local' must not crash and
    # must return EMBED_DIM vectors (either the real model or the hashed fallback).
    e = build_embedder("local")
    assert e.dim == EMBED_DIM
    out = e.embed(["hello world"])
    assert len(out) == 1 and len(out[0]) == EMBED_DIM


def test_service_hashed_backend_is_explicit():
    e = build_embedder("hashed")
    assert e.name == "hashed"
    assert e.dim == EMBED_DIM
