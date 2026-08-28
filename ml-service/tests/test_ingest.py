from app.services.assistant.embeddings.base import EMBED_DIM
from app.services.assistant.embeddings.hashed import HashedEmbedder
from app.services.assistant.ingest import build_chunk_rows

_ARTICLE = (
    "GIGGO protects both sides with escrow. " * 40
    + "When you pay for a completed job, the money is held securely. " * 40
)


def test_build_chunk_rows_produces_embedded_indexed_chunks():
    embedder = HashedEmbedder()
    rows = build_chunk_rows("art-1", "how-escrow-works", _ARTICLE, embedder)

    assert len(rows) > 1  # long article splits into several chunks
    # chunk_index is dense and ordered from zero
    assert [r.chunk_index for r in rows] == list(range(len(rows)))
    # every row carries the article reference, the model name and a 384-dim vector
    for r in rows:
        assert r.article_id == "art-1"
        assert r.article_slug == "how-escrow-works"
        assert r.embedding_model == "hashed"
        assert len(r.embedding) == EMBED_DIM
        assert r.content


def test_build_chunk_rows_handles_empty_article():
    assert build_chunk_rows("art-2", "empty", "   ", HashedEmbedder()) == []
