"""Guards RAG assistant quality against regressions (RAG-10, quality gate).

Runs the golden set through the same retrieval + answer pipeline (in-memory, no
DB) and fails if retrieval, citation, groundedness or refusal drop below their
floors. Refusal is gated from Phase 3 on (the guardrails make it discriminative).
"""

from app.services.assistant.answer.extractive import LocalExtractiveAnswerer
from app.services.assistant.embeddings import get_embedder
from evaluation.assistant_eval import (
    CITATION_FLOOR,
    GROUNDEDNESS_FLOOR,
    REFUSAL_FLOOR,
    RETRIEVAL_FLOOR,
    InMemoryRetriever,
    default_corpus,
    default_dataset,
    evaluate,
    load_jsonl,
)


def test_golden_set_is_reasonably_sized():
    assert len(load_jsonl(default_dataset())) >= 30


def test_assistant_quality_meets_floors():
    golden = load_jsonl(default_dataset())
    corpus = load_jsonl(default_corpus())
    retriever = InMemoryRetriever(corpus, get_embedder())
    metrics = evaluate(golden, retriever, LocalExtractiveAnswerer())

    assert metrics["retrieval_hit_rate"] >= RETRIEVAL_FLOOR, metrics
    assert metrics["citation_correctness"] >= CITATION_FLOOR, metrics
    assert metrics["groundedness"] >= GROUNDEDNESS_FLOOR, metrics
    assert metrics["refusal_accuracy"] >= REFUSAL_FLOOR, metrics
