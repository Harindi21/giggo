"""Offline evaluation of the RAG assistant (RAG-06..RAG-10).

Builds an in-memory index over a fixed article corpus (a golden fixture) and runs
the SAME retrieval + answer pipeline used in production, scoring:

- retrieval hit-rate@k  - is the expected article among the top-k chunks,
- citation correctness  - does the answer cite the expected article,
- groundedness          - is the answer supported by the retrieved chunks,
- refusal accuracy      - are off-topic questions refused (grounded=False).

It needs no database (it embeds the corpus in memory), so it runs anywhere and
in CI, using whatever embedder is configured: the keyless hashed fallback in CI,
sentence-transformers locally. The scores therefore reflect the backend in use.

    python -m evaluation.assistant_eval [--dataset path.jsonl] [--corpus path.jsonl]
"""

from __future__ import annotations

import argparse
import json
import os
import re
from dataclasses import dataclass

from app.services.assistant.answer.extractive import LocalExtractiveAnswerer
from app.services.assistant.chunking import chunk_text
from app.services.assistant.embeddings import Embedder, get_embedder
from app.services.assistant.pipeline import answer_question
from app.services.assistant.retrieval import RetrievedChunk

# The eval uses a small top-k so retrieval is discriminative over a tiny corpus,
# and a lenient min score (production uses the pipeline default).
EVAL_TOP_K = 2
EVAL_MIN_SCORE = 0.02

# Quality floors, set below the current hashed-embedder baseline (see the eval
# README) so CI passes while still catching a real regression. Raise them as the
# corpus and the embedding backend improve.
RETRIEVAL_FLOOR = 0.80
CITATION_FLOOR = 0.75
GROUNDEDNESS_FLOOR = 0.85
# Refusal of off-topic questions is reported but NOT gated here: the keyless
# hashed fallback embedder cannot separate off-topic from on-topic by cosine
# similarity alone (common words overlap). Hardening refusal - and gating on it -
# is Phase 3 (RAG-11..RAG-13), where sentence-transformers plus a domain gate
# make it discriminative.


def _here() -> str:
    return os.path.dirname(__file__)


def default_dataset() -> str:
    return os.path.join(_here(), "assistant_eval.jsonl")


def default_corpus() -> str:
    return os.path.join(_here(), "assistant_corpus.jsonl")


def load_jsonl(path: str) -> list[dict]:
    rows: list[dict] = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


@dataclass
class _IndexedChunk:
    content: str
    slug: str
    title: str
    vector: list[float]


class InMemoryRetriever:
    """Retriever protocol implementation backed by an in-memory cosine index."""

    def __init__(self, corpus: list[dict], embedder: Embedder) -> None:
        self._embedder = embedder
        self._index: list[_IndexedChunk] = []
        for article in corpus:
            for chunk in chunk_text(article["content"]):
                vector = embedder.embed([chunk])[0]
                self._index.append(
                    _IndexedChunk(chunk, article["slug"], article["title"], vector)
                )

    def retrieve(self, question: str, top_k: int) -> list[RetrievedChunk]:
        q = self._embedder.embed([question])[0]
        scored = [
            (sum(a * b for a, b in zip(q, c.vector)), c) for c in self._index
        ]
        scored.sort(key=lambda pair: pair[0], reverse=True)
        return [
            RetrievedChunk(c.content, c.slug, c.title, float(score))
            for score, c in scored[:top_k]
        ]


_WORD = re.compile(r"[a-z0-9]+")


def _tokens(text: str) -> set[str]:
    return set(_WORD.findall(text.lower()))


def _groundedness(answer_text: str, chunks: list[RetrievedChunk]) -> float:
    """Fraction of answer tokens supported by the retrieved chunk text."""
    answer_tokens = _tokens(answer_text)
    if not answer_tokens:
        return 1.0
    support: set[str] = set()
    for c in chunks:
        support |= _tokens(c.content)
    return len(answer_tokens & support) / len(answer_tokens)


def evaluate(
    golden: list[dict],
    retriever: InMemoryRetriever,
    answerer: LocalExtractiveAnswerer,
    top_k: int = EVAL_TOP_K,
    min_score: float = EVAL_MIN_SCORE,
) -> dict:
    ret_hits = ret_total = 0
    cite_hits = cite_total = 0
    ground_sum = 0.0
    ground_n = 0
    refuse_hits = refuse_total = 0

    for row in golden:
        question = row["question"]
        expected = row.get("expected_slug")
        answer, _retrieved = answer_question(
            question,
            retriever=retriever,
            answerer=answerer,
            top_k=top_k,
            min_score=min_score,
        )
        top = retriever.retrieve(question, top_k)
        top_slugs = [c.article_slug for c in top]

        if expected is None:
            refuse_total += 1
            if not answer.grounded:
                refuse_hits += 1
            continue

        ret_total += 1
        if expected in top_slugs:
            ret_hits += 1
        if answer.grounded:
            cite_total += 1
            if expected in [c.slug for c in answer.citations]:
                cite_hits += 1
            ground_sum += _groundedness(answer.text, top)
            ground_n += 1

    return {
        "retrieval_hit_rate": ret_hits / ret_total if ret_total else 0.0,
        "citation_correctness": cite_hits / cite_total if cite_total else 0.0,
        "groundedness": ground_sum / ground_n if ground_n else 0.0,
        "refusal_accuracy": refuse_hits / refuse_total if refuse_total else 1.0,
        "answerable": ret_total,
        "off_topic": refuse_total,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset", default=default_dataset())
    parser.add_argument("--corpus", default=default_corpus())
    args = parser.parse_args()

    golden = load_jsonl(args.dataset)
    corpus = load_jsonl(args.corpus)
    embedder = get_embedder()
    retriever = InMemoryRetriever(corpus, embedder)
    metrics = evaluate(golden, retriever, LocalExtractiveAnswerer())

    print(
        f"RAG assistant eval on {metrics['answerable']} answerable + "
        f"{metrics['off_topic']} off-topic questions "
        f"(embedder: {getattr(embedder, 'name', '?')}, top_k={EVAL_TOP_K})\n"
    )
    checks = [
        ("retrieval hit-rate", metrics["retrieval_hit_rate"], RETRIEVAL_FLOOR),
        ("citation correctness", metrics["citation_correctness"], CITATION_FLOOR),
        ("groundedness", metrics["groundedness"], GROUNDEDNESS_FLOOR),
    ]
    ok = True
    print(f"{'metric':<22}{'score':>8}{'floor':>8}  status")
    for name, score, floor in checks:
        passed = score >= floor
        ok = ok and passed
        print(f"{name:<22}{score:>8.2f}{floor:>8.2f}  {'PASS' if passed else 'FAIL'}")
    print(
        f"{'refusal accuracy':<22}{metrics['refusal_accuracy']:>8.2f}{'-':>8}"
        "  info (gated in Phase 3)"
    )
    print("\n" + ("All gated checks passed." if ok else "Quality below floor."))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
