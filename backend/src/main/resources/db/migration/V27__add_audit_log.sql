-- Admin audit log (P11.10): an append-only record of privileged actions
-- (KYC decisions, dispute resolutions, review moderation, payout processing,
-- commission changes), for compliance and traceability.

CREATE TABLE audit_log (
    id           UUID PRIMARY KEY,
    actor_id     UUID NOT NULL,
    action       VARCHAR(60) NOT NULL,
    target_type  VARCHAR(40),
    target_id    UUID,
    detail       VARCHAR(500),
    created_at   TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_audit_log_created ON audit_log (created_at DESC);
CREATE INDEX idx_audit_log_actor ON audit_log (actor_id);
