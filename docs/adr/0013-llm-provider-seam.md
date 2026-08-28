# ADR-0013: LLM provider seam for the assistant

- **Status:** Accepted
- **Date:** 2026-08-28

## Context
The RAG assistant needs two model-backed steps: **embedding** (turn text into vectors
for retrieval) and **generation** (turn retrieved chunks + a question into a grounded
answer). Good hosted options exist but they cost money and need API keys. Per
[ADR-0001](0001-integration-seams-with-stub-defaults.md), day-to-day development and
the demo must run **free and keyless**, while staying a one-line swap away from a real
provider.

## Decision
Put both steps behind **config-selected backends**, mirroring `sentiment_backend` /
`recommender_backend` in `ml-service/app/core/config.py`:

- `embedding_backend` — **`"local"`** (default): a local sentence-embedding model
  (`sentence-transformers`, e.g. `all-MiniLM-L6-v2`), runs offline, no key. Swap-in: a
  hosted embeddings API.
- `assistant_backend` — **`"local"`** (default): a keyless, grounded answer built from
  the retrieved chunks (extractive / templated over the top passages), which is honest
  about only using the corpus and costs nothing. Swap-in: a hosted instruct LLM
  (`assistant_model` names the model; the API key comes from the environment, never
  code).

Selection lives in a `service.py` factory alongside the backends, exactly like the
sentiment and recommender packages. Secrets are read from env only.

## Alternatives considered
- **Hard-code a hosted LLM** — needs keys to run at all, costs money on every dev
  request, and couples the pipeline to one vendor. Rejected by ADR-0001.
- **Local-only, no seam** — free, but no path to the higher answer quality a hosted
  model gives for the final demo, and no way to compare the two under the eval.

## Consequences
- The assistant runs end-to-end for free and offline; enabling a hosted model is a
  config + env-var change, not a rewrite.
- The local default's answer quality is lower than a hosted LLM's — **acceptable and
  measured**: the Phase-2 evaluation scores both backends on the same golden set, and
  Phase-4 tracks the hosted backend's token cost so the trade-off is visible, not
  hidden.
- One more indirection layer; each real backend still has to be written and tested when
  adopted (same trade-off ADR-0001 already accepts).
