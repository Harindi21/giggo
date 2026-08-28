"""In-process observability for the RAG assistant (RAG-14..RAG-16).

Records a lightweight trace per ``/ask`` (latency, retrieved chunks, token
counts, estimated cost, grounded/refused) into a bounded rolling window, and
exposes an aggregate snapshot (p50/p95/p99 latency, cost per question, volume,
grounded and refusal rates) plus threshold alerts. Keyless and dependency-free:
the data lives in memory and is served as JSON for the dashboard, and the same
call sites can be scraped into Prometheus/Grafana later without change.
"""

from __future__ import annotations

import re
from collections import deque
from dataclasses import dataclass
from threading import Lock

from app.core.config import settings

_WORD = re.compile(r"\S+")


def estimate_tokens(text: str) -> int:
    """Rough token count without a tokenizer: ~1.3 tokens per whitespace word."""
    words = len(_WORD.findall(text or ""))
    return int(round(words * 1.3))


def estimate_cost(tokens_in: int, tokens_out: int) -> float:
    return (
        tokens_in / 1000.0 * settings.assistant_cost_per_1k_input
        + tokens_out / 1000.0 * settings.assistant_cost_per_1k_output
    )


@dataclass
class RequestTrace:
    at: float  # epoch seconds
    latency_ms: float
    retrieved: int
    tokens_in: int
    tokens_out: int
    cost_usd: float
    grounded: bool
    refused: bool


def percentile(sorted_values: list[float], pct: float) -> float:
    if not sorted_values:
        return 0.0
    k = (len(sorted_values) - 1) * pct
    lo = int(k)
    hi = min(lo + 1, len(sorted_values) - 1)
    return sorted_values[lo] + (sorted_values[hi] - sorted_values[lo]) * (k - lo)


def check_alerts(snap: dict) -> list[dict]:
    """RAG-16: fire an alert when a rolling metric crosses its threshold."""
    alerts: list[dict] = []
    p95 = snap["latency_ms"]["p95"]
    if p95 > settings.alert_p95_latency_ms:
        alerts.append(
            {
                "metric": "p95_latency_ms",
                "value": p95,
                "threshold": settings.alert_p95_latency_ms,
                "message": f"p95 latency {p95}ms over {settings.alert_p95_latency_ms}ms",
            }
        )
    avg_cost = snap["cost_usd"]["avg_per_question"]
    if avg_cost > settings.alert_avg_cost_usd:
        alerts.append(
            {
                "metric": "avg_cost_usd",
                "value": avg_cost,
                "threshold": settings.alert_avg_cost_usd,
                "message": f"avg cost ${avg_cost} over ${settings.alert_avg_cost_usd}",
            }
        )
    refusal = snap["refusal_rate"]
    if refusal > settings.alert_refusal_rate:
        alerts.append(
            {
                "metric": "refusal_rate",
                "value": refusal,
                "threshold": settings.alert_refusal_rate,
                "message": (
                    f"refusal rate {refusal} over {settings.alert_refusal_rate} "
                    "(possible corpus gaps)"
                ),
            }
        )
    return alerts


class MetricsStore:
    def __init__(self, maxlen: int = 1000) -> None:
        self._traces: deque[RequestTrace] = deque(maxlen=maxlen)
        self._lock = Lock()

    def record(self, trace: RequestTrace) -> None:
        with self._lock:
            self._traces.append(trace)

    def clear(self) -> None:
        with self._lock:
            self._traces.clear()

    def snapshot(self) -> dict:
        with self._lock:
            traces = list(self._traces)
        n = len(traces)
        if n == 0:
            return {
                "requests": 0,
                "latency_ms": {"p50": 0.0, "p95": 0.0, "p99": 0.0},
                "cost_usd": {"total": 0.0, "avg_per_question": 0.0},
                "tokens": {"avg_in": 0.0, "avg_out": 0.0},
                "grounded_rate": 0.0,
                "refusal_rate": 0.0,
                "alerts": [],
            }
        latencies = sorted(t.latency_ms for t in traces)
        total_cost = sum(t.cost_usd for t in traces)
        snap = {
            "requests": n,
            "latency_ms": {
                "p50": round(percentile(latencies, 0.50), 1),
                "p95": round(percentile(latencies, 0.95), 1),
                "p99": round(percentile(latencies, 0.99), 1),
            },
            "cost_usd": {
                "total": round(total_cost, 6),
                "avg_per_question": round(total_cost / n, 6),
            },
            "tokens": {
                "avg_in": round(sum(t.tokens_in for t in traces) / n, 1),
                "avg_out": round(sum(t.tokens_out for t in traces) / n, 1),
            },
            "grounded_rate": round(sum(1 for t in traces if t.grounded) / n, 3),
            "refusal_rate": round(sum(1 for t in traces if t.refused) / n, 3),
        }
        snap["alerts"] = check_alerts(snap)
        return snap


metrics_store = MetricsStore()
