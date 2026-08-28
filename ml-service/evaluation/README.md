# ML evaluation harnesses

Offline, golden-set evaluations that gate model/pipeline quality. Each runs as a
plain command and as a pytest, so a regression fails CI (the Phase-5 quality gate
builds on this).

## Sentiment (`sentiment_eval.py`)
Labelled reviews scored for accuracy against a floor. See `test_sentiment_eval.py`.

## RAG assistant (`assistant_eval.py`)

Builds an in-memory index over `assistant_corpus.jsonl` (a fixed golden copy of
the Knowledge Hub articles) and runs the **same** retrieval + answer pipeline used
in production, scoring the labelled questions in `assistant_eval.jsonl`:

- **retrieval hit-rate@k** - is the expected article among the top-k chunks
- **citation correctness** - does the answer cite the expected article
- **groundedness** - are the answer's tokens supported by the retrieved chunks
- **refusal accuracy** - are off-topic and prompt-injection questions refused (gated from Phase 3)

No database is needed: the corpus is embedded in memory with the configured
embedder. In CI that is the keyless **hashed** fallback; install
`sentence-transformers` locally for the real semantic backend (scores go up).

Run it:

```
cd ml-service
python -m evaluation.assistant_eval
```

### Baseline (hashed embedder, 31 answerable + 7 off-topic/adversarial questions, top_k=2)

| metric | score | floor | gated |
|---|---|---|---|
| retrieval hit-rate | 0.90 | 0.80 | yes |
| citation correctness | 0.90 | 0.75 | yes |
| groundedness | 0.97 | 0.85 | yes |
| refusal accuracy | 1.00 | 0.90 | yes |

Refusal was 0.00 with cosine alone (common stop-words make off-topic questions
overlap the corpus, so a similarity threshold cannot separate them). The Phase 3
guardrails - a content-word overlap gate plus prompt-injection detection - fix
that even on the keyless hashed embedder, taking refusal to 1.00, so it is now
gated. Floors sit below the current scores so CI passes while still catching a real
regression; raise them as the corpus and backend improve.
