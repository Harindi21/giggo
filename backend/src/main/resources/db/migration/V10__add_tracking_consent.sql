-- Opt-in, time-boxed consent for live location sharing during a job (P5.2).
-- Privacy-first: no provider location is broadcast unless an active GRANTED
-- consent exists for the job. job_id references a future bookings row
-- (Phase B); no FK yet, so tracking can be built independently.

CREATE TABLE tracking_consents (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id       UUID NOT NULL,
    customer_id  UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    provider_id  UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    requested_by UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    status       VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    granted_at   TIMESTAMPTZ,
    expires_at   TIMESTAMPTZ,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_tracking_consents_job ON tracking_consents (job_id);

-- At most one live/pending consent per job at a time.
CREATE UNIQUE INDEX uq_tracking_consents_active
    ON tracking_consents (job_id) WHERE status IN ('PENDING', 'GRANTED');
