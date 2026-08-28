from fastapi.testclient import TestClient

from app.api.v1 import assistant as assistant_api
from app.main import app
from app.services.assistant.retrieval import RetrievedChunk

client = TestClient(app)


class _FakeRetriever:
    def __init__(self, chunks):
        self._chunks = chunks

    def retrieve(self, question, top_k):
        return self._chunks


def _use_chunks(chunks):
    app.dependency_overrides[assistant_api.retriever_dependency] = (
        lambda: _FakeRetriever(chunks)
    )


def teardown_function(_):
    app.dependency_overrides.clear()


def test_ask_requires_api_key():
    res = client.post("/api/v1/assistant/ask", json={"question": "how does escrow work"})
    assert res.status_code == 401


def test_ask_returns_grounded_answer_with_citations():
    _use_chunks(
        [
            RetrievedChunk(
                "Escrow holds your money until the job is done.",
                "how-payments-and-escrow-work",
                "Payments & escrow: how it works",
                0.8,
            )
        ]
    )
    res = client.post(
        "/api/v1/assistant/ask",
        json={"question": "how does escrow work"},
        headers={"X-API-Key": "local-dev-key"},
    )
    assert res.status_code == 200
    body = res.json()
    assert body["grounded"] is True
    assert body["retrieved_chunks"] == 1
    assert body["citations"][0]["slug"] == "how-payments-and-escrow-work"
    assert "Escrow holds your money" in body["answer"]


def test_ask_refuses_when_corpus_has_nothing():
    _use_chunks([])
    res = client.post(
        "/api/v1/assistant/ask",
        json={"question": "what is the weather today"},
        headers={"X-API-Key": "local-dev-key"},
    )
    assert res.status_code == 200
    body = res.json()
    assert body["grounded"] is False
    assert body["citations"] == []
