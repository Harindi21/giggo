from app.services.assistant.answer.extractive import LocalExtractiveAnswerer
from app.services.assistant.pipeline import answer_question
from app.services.assistant.retrieval import RetrievedChunk


class _FakeRetriever:
    def __init__(self, chunks):
        self._chunks = chunks
        self.calls = []

    def retrieve(self, question, top_k):
        self.calls.append((question, top_k))
        return self._chunks


def _chunk(score, slug="escrow", title="Escrow"):
    return RetrievedChunk(
        content="Escrow holds funds until the job is done.",
        article_slug=slug,
        article_title=title,
        score=score,
    )


def test_pipeline_answers_from_relevant_chunks():
    fake = _FakeRetriever([_chunk(0.8), _chunk(0.5)])
    ans, retrieved = answer_question(
        "how does escrow work",
        retriever=fake,
        answerer=LocalExtractiveAnswerer(),
        top_k=4,
    )
    assert retrieved == 2
    assert ans.grounded is True
    assert fake.calls == [("how does escrow work", 4)]


def test_pipeline_refuses_when_nothing_retrieved():
    ans, retrieved = answer_question(
        "unrelated",
        retriever=_FakeRetriever([]),
        answerer=LocalExtractiveAnswerer(),
    )
    assert retrieved == 0
    assert ans.grounded is False


def test_pipeline_filters_low_similarity_chunks():
    fake = _FakeRetriever([_chunk(0.02)])  # below the min score
    ans, retrieved = answer_question(
        "weakly related",
        retriever=fake,
        answerer=LocalExtractiveAnswerer(),
        min_score=0.1,
    )
    assert retrieved == 1  # it was retrieved
    assert ans.grounded is False  # but dropped as too weak -> refusal
