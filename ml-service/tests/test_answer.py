from app.services.assistant.answer.extractive import LocalExtractiveAnswerer
from app.services.assistant.retrieval import RetrievedChunk


def _chunk(content, slug, title, score):
    return RetrievedChunk(
        content=content, article_slug=slug, article_title=title, score=score
    )


def test_extractive_answer_is_grounded_and_cites_sources():
    answerer = LocalExtractiveAnswerer(max_chunks=2)
    chunks = [
        _chunk("Escrow holds your money until the job is done.", "escrow", "Escrow", 0.8),
        _chunk("Once you release it, the provider is paid.", "escrow", "Escrow", 0.6),
    ]
    ans = answerer.answer("how does escrow work", chunks)
    assert ans.grounded is True
    assert "Escrow holds your money" in ans.text
    assert [c.slug for c in ans.citations] == ["escrow"]  # de-duped by slug
    assert ans.backend == "local-extractive"


def test_extractive_refuses_when_no_chunks():
    ans = LocalExtractiveAnswerer().answer("anything", [])
    assert ans.grounded is False
    assert ans.citations == []


def test_extractive_uses_only_the_top_chunks():
    answerer = LocalExtractiveAnswerer(max_chunks=2)
    chunks = [
        _chunk("A about escrow", "escrow", "Escrow", 0.9),
        _chunk("B about safety", "safety", "Safety", 0.7),
        _chunk("C not used", "verify", "Verify", 0.5),
    ]
    ans = answerer.answer("q", chunks)
    assert [c.slug for c in ans.citations] == ["escrow", "safety"]
