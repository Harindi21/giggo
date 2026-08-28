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
- **refusal accuracy** - are off-topic questions refused (reported, not yet gated)

No database is needed: the corpus is embedded in memory with the configured
embedder. In CI that is the keyless **hashed** fallback; install
`sentence-transformers` locally for the real semantic backend (scores go up).

Run it:

```
cd ml-service
python -m evaluation.assistant_eval
```

### Baseline (hashed embedder, 31 answerable + 4 off-topic questions, top_k=2)

| metric | score | floor | gated |
|---|---|---|---|
| retrieval hit-rate | 0.90 | 0.80 | yes |
| citation correctness | 0.90 | 0.75 | yes |
| groundedness | 0.97 | 0.85 | yes |
| refusal accuracy | 0.00 | - | no (Phase 3) |

Refusal is 0.00 on the hashed embedder because common stop-words make off-topic
questions overlap the corpus; a cosine threshold alone cannot separate them. This
is expected and is hardened in Phase 3 (RAG-11..RAG-13) with a domain gate and the
semantic embedder. Floors sit below the current scores so CI passes while still
catching a real regression; raise them as the corpus and backend improve.
