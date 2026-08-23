"""Guards NLP sentiment accuracy against regressions (P12.10).

Runs the labelled review set through the analyzer and fails if overall accuracy
drops below the floor. The floor sits below the current score so the labelled
set can grow with harder examples without breaking CI on the first tricky case.
"""

from evaluation.sentiment_eval import default_dataset, evaluate, load

ACCURACY_FLOOR = 0.80


def test_labelled_set_is_reasonably_sized():
    rows = load(default_dataset())
    assert len(rows) >= 40


def test_sentiment_accuracy_meets_floor():
    rows = load(default_dataset())
    accuracy, _metrics, _confusion, _total = evaluate(rows)
    assert accuracy >= ACCURACY_FLOOR, f"sentiment accuracy {accuracy:.1%} below floor"
