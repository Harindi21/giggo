import time

from fastapi import APIRouter, Depends
from fastapi.responses import HTMLResponse

from app.core.security import require_api_key
from app.schemas.assistant import AskRequest, AskResponse, CitationOut
from app.services.assistant.metrics import (
    RequestTrace,
    estimate_cost,
    estimate_tokens,
    metrics_store,
)
from app.services.assistant.pipeline import answer_question
from app.services.assistant.retrieval import Retriever, get_retriever

router = APIRouter(prefix="/assistant", tags=["assistant"])


def retriever_dependency() -> Retriever:
    # Indirected so tests can override it with a fake retriever (no DB in CI).
    return get_retriever()


@router.post("/ask", response_model=AskResponse)
async def ask(
    payload: AskRequest,
    retriever: Retriever = Depends(retriever_dependency),
    _=Depends(require_api_key),
):
    started = time.perf_counter()
    answer, retrieved = answer_question(
        payload.question, retriever=retriever, top_k=payload.top_k
    )
    latency_ms = (time.perf_counter() - started) * 1000.0

    tokens_in = estimate_tokens(payload.question)
    tokens_out = estimate_tokens(answer.text)
    metrics_store.record(
        RequestTrace(
            at=time.time(),
            latency_ms=latency_ms,
            retrieved=retrieved,
            tokens_in=tokens_in,
            tokens_out=tokens_out,
            cost_usd=estimate_cost(tokens_in, tokens_out),
            grounded=answer.grounded,
            refused=not answer.grounded,
        )
    )

    return AskResponse(
        answer=answer.text,
        grounded=answer.grounded,
        citations=[CitationOut(slug=c.slug, title=c.title) for c in answer.citations],
        retrieved_chunks=retrieved,
        backend=answer.backend,
    )


@router.get("/metrics")
async def metrics():
    # Open like /health: operational metrics, not user data. Powers the dashboard
    # and is scrapeable by Prometheus/Grafana.
    return metrics_store.snapshot()


@router.get("/dashboard", response_class=HTMLResponse)
async def dashboard():
    return _DASHBOARD_HTML


_DASHBOARD_HTML = """<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>GIGGO Assistant - Observability</title>
<style>
  :root { --navy:#121D4A; --orange:#FF851C; --blue:#D2E5FF; --muted:#6B7280; }
  * { box-sizing: border-box; }
  body { margin:0; font-family: system-ui, Segoe UI, Roboto, sans-serif; background:#F7F7F7; color:var(--navy); }
  header { background:var(--navy); color:#fff; padding:20px 24px; }
  header h1 { margin:0; font-size:20px; } header p { margin:4px 0 0; color:#c9d4f0; font-size:13px; }
  main { padding:24px; max-width:900px; margin:0 auto; }
  .grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:14px; }
  .card { background:#fff; border-radius:14px; padding:16px; box-shadow:0 1px 3px rgba(0,0,0,.06); }
  .card .label { font-size:12px; color:var(--muted); text-transform:uppercase; letter-spacing:.4px; }
  .card .value { font-size:26px; font-weight:800; margin-top:6px; }
  .card .sub { font-size:12px; color:var(--muted); margin-top:2px; }
  .alerts { margin-top:20px; }
  .alert { background:#FDECEC; border-left:4px solid #DC2626; color:#991B1B; padding:12px 14px; border-radius:10px; margin-bottom:10px; font-size:14px; }
  .ok { background:#E9F7EF; border-left-color:#16A34A; color:#166534; }
  footer { color:var(--muted); font-size:12px; text-align:center; padding:16px; }
</style></head>
<body>
<header><h1>GIGGO Assistant - Observability</h1><p>Live latency, cost and quality for /assistant/ask. Auto-refreshes every 3s.</p></header>
<main>
  <div class="grid" id="grid"></div>
  <div class="alerts" id="alerts"></div>
</main>
<footer>Keyless local dashboard - reads /api/v1/assistant/metrics</footer>
<script>
function card(label, value, sub){ return `<div class="card"><div class="label">${label}</div><div class="value">${value}</div><div class="sub">${sub||''}</div></div>`; }
async function tick(){
  try {
    const r = await fetch('metrics'); const m = await r.json();
    const lat = m.latency_ms, cost = m.cost_usd;
    document.getElementById('grid').innerHTML = [
      card('Requests', m.requests, 'rolling window'),
      card('p50 latency', lat.p50 + ' ms', 'p95 ' + lat.p95 + ' / p99 ' + lat.p99),
      card('Avg cost / q', '$' + cost.avg_per_question.toFixed(4), 'total $' + cost.total.toFixed(4)),
      card('Avg tokens', m.tokens.avg_in + ' / ' + m.tokens.avg_out, 'in / out'),
      card('Grounded', (m.grounded_rate*100).toFixed(0) + '%', 'answered from corpus'),
      card('Refusals', (m.refusal_rate*100).toFixed(0) + '%', 'off-topic / injection'),
    ].join('');
    const a = m.alerts || [];
    document.getElementById('alerts').innerHTML = a.length
      ? a.map(x => `<div class="alert">ALERT: ${x.message}</div>`).join('')
      : '<div class="alert ok">No alerts firing.</div>';
  } catch(e){ document.getElementById('alerts').innerHTML = '<div class="alert">Could not load metrics.</div>'; }
}
tick(); setInterval(tick, 3000);
</script>
</body></html>"""
