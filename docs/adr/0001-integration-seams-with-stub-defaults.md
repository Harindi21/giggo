# ADR-0001: External integrations behind adapter seams with stub defaults

- **Status:** Accepted
- **Date:** 2026-08-08

## Context
GIGGO depends on several paid/keyed third parties — a maps provider, a payment
gateway (PayHere), push (FCM), an email sender, and heavy ML models (RoBERTa,
LightFM). During development we had no credentials, and the goal was a system that
runs and demos end-to-end from day one without blocking on procurement, while still
being production-ready once keys exist.

## Decision
Every external dependency sits behind an **adapter interface** with a **working stub
implementation as the default**, selected by configuration. The stub is real,
exercisable code (not a mock) — it logs, returns deterministic data, or computes a
local approximation — so the full flow works without any keys. Examples:
`PaymentGateway` (StubPaymentGateway), `PushSender` (StubPushSender), the sentiment
analyzer (`SENTIMENT_BACKEND`), the recommender (`RECOMMENDER_BACKEND`), and maps.

## Alternatives considered
- **Hard-code the real SDKs** and gate features behind keys — blocks development and
  demos; couples business logic to vendor SDKs.
- **Mocks in tests only** — leaves the running app broken without keys.

## Consequences
- The app is fully runnable and demoable with zero paid keys; going live is a
  config-level swap, not a rewrite.
- Business logic never imports a vendor SDK directly — it depends on our interface.
- Slight extra indirection, and each real adapter still has to be written and tested
  when adopted. A few flows are intentionally simplified in stub form (e.g. the map,
  gateway capture) and documented as such.
