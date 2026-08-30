# ADR-0014: Rollout and rollback for assistant prompt/model changes

- **Status:** Accepted
- **Date:** 2026-08-30

## Context
The RAG assistant's behaviour depends on several quality-affecting inputs: the
prompt/answer templates, the embedding and answer backends and their model ids,
the retrieval and relevance thresholds, and the built index. A careless change to
any of them can quietly degrade answers or raise cost. We need a way to ship such
changes safely and undo them quickly, without a heavyweight CD platform.

## Decision
Lean on the pieces already built:

- **Gate every quality-affecting change.** Prompts, thresholds, backends and model
  ids change only through a PR that must pass the **CI quality gate** (RAG-19,
  `python -m evaluation.assistant_eval`). A change that drops retrieval, citation,
  groundedness or refusal below the floors cannot merge.
- **Rollback is a config or git revert, not a redeploy of new code.** Backends are
  config-selected (ADR-0013), so switching model/backend is an env change; prompts
  and settings are versioned in one place (RAG-17), so reverting a prompt is a
  `git revert`.
- **The index is reproducible** (RAG-18) with a pinned embedding model, and the
  ingestion job is idempotent, so re-running it restores a known-good index.
- **Canary (manual for now).** Roll a new config to one instance or behind a flag,
  watch the Phase-4 dashboard (latency, cost, refusal rate) and run the eval
  against the live corpus, then roll forward or revert. The alert rules (RAG-16)
  surface a regression in latency, cost or refusal rate.

## Alternatives considered
- **Ship without a gate** - fastest, but nothing stops a worse version reaching
  users; rejected, since the gate is the whole point of the project.
- **A full automated canary / progressive-delivery system** - the right end state
  at scale, but overkill now; the CI gate plus config-swap rollback plus the
  dashboard give most of the safety for a fraction of the effort.

## Consequences
- Shipping an assistant change is a reviewed, measured, reversible operation, with
  the CI gate as the enforcement point and the dashboard as the watch.
- Rollback is fast (revert a config/prompt commit; re-run the idempotent ingest).
- A real automated canary/CD can layer on later without changing these seams.
