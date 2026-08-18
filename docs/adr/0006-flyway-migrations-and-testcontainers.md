# ADR-0006: Migration-only schema + full-context test on Testcontainers

- **Status:** Accepted
- **Date:** 2026-08-16

## Context
The schema must evolve safely across many features without drift between environments,
and we need confidence that every migration applies cleanly and that the JPA mapping
matches the real database — not just an in-memory H2 approximation.

## Decision
- **Schema changes only via Flyway migrations** (`V1…Vnn`); Hibernate runs with
  `ddl-auto=validate` (never `update`/`create`), so the app refuses to start if an
  entity and the schema disagree.
- **CI runs a full Spring context test against a real Postgres via Testcontainers**
  (`@SpringBootTest` + `@ServiceConnection`). Flyway applies **every migration from
  scratch** on a throwaway container each run, and Hibernate validates the mapping.

## Alternatives considered
- **`ddl-auto=update`** — silent, unversioned schema drift; unrepeatable.
- **H2 for tests** — fast but lies about Postgres-specific SQL (types, `gen_random_uuid`,
  constraints), giving false confidence.

## Consequences
- The migrate-from-zero path and entity/schema agreement are verified on every PR;
  a bad migration fails the build before merge.
- Tests require Docker (present on CI and dev); the context test adds a few seconds.
- Migrations are immutable once merged — fixes go in a new migration.
