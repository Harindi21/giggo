"""NLP sentiment-accuracy evaluation (P12.10).

Runs a labelled review set through the sentiment analyzer and reports overall
accuracy, per-class precision/recall/F1, and a confusion matrix. Grow
``labelled_reviews.jsonl`` toward the 200-review target as more labels land.

    python -m evaluation.sentiment_eval [--dataset path.jsonl]
"""

from __future__ import annotations

import argparse
import json
import os
from collections import Counter, defaultdict

from app.services.sentiment import analyze

LABELS = ["positive", "neutral", "negative"]


def default_dataset() -> str:
    return os.path.join(os.path.dirname(__file__), "labelled_reviews.jsonl")


def load(path: str) -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line)
            rows.append((obj["text"], obj["label"]))
    return rows


def evaluate(rows: list[tuple[str, str]]):
    confusion: dict[str, Counter] = defaultdict(Counter)
    correct = 0
    for text, gold in rows:
        pred = analyze(text).label
        confusion[gold][pred] += 1
        if pred == gold:
            correct += 1
    total = len(rows)
    accuracy = correct / total if total else 0.0
    metrics = {}
    for c in LABELS:
        tp = confusion[c][c]
        fp = sum(confusion[g][c] for g in LABELS if g != c)
        fn = sum(confusion[c][p] for p in LABELS if p != c)
        prec = tp / (tp + fp) if tp + fp else 0.0
        rec = tp / (tp + fn) if tp + fn else 0.0
        f1 = 2 * prec * rec / (prec + rec) if prec + rec else 0.0
        metrics[c] = {"precision": prec, "recall": rec, "f1": f1, "support": tp + fn}
    return accuracy, metrics, confusion, total


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset", default=default_dataset())
    args = parser.parse_args()

    rows = load(args.dataset)
    accuracy, metrics, confusion, total = evaluate(rows)

    print(f"NLP sentiment accuracy: {accuracy:.1%} on {total} labelled reviews\n")
    print(f"{'class':<10}{'prec':>7}{'rec':>7}{'f1':>7}{'n':>6}")
    for c in LABELS:
        m = metrics[c]
        print(f"{c:<10}{m['precision']:>7.2f}{m['recall']:>7.2f}{m['f1']:>7.2f}{m['support']:>6}")
    print("\nConfusion (rows = gold, cols = predicted):")
    print(f"{'':<10}" + "".join(f"{c:>10}" for c in LABELS))
    for g in LABELS:
        print(f"{g:<10}" + "".join(f"{confusion[g][p]:>10}" for p in LABELS))


if __name__ == "__main__":
    main()
