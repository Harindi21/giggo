-- Booking disputes (P4.6): a participant can raise a dispute on a job;
-- an admin resolves it (refund via escrow, or dismiss).

CREATE TABLE disputes (
    id               UUID PRIMARY KEY,
    booking_id       UUID NOT NULL UNIQUE REFERENCES bookings (id),
    raised_by        UUID NOT NULL,
    reason           VARCHAR(1000) NOT NULL,
    status           VARCHAR(24) NOT NULL,
    resolution_note  VARCHAR(1000),
    resolved_by      UUID,
    created_at       TIMESTAMPTZ NOT NULL,
    resolved_at      TIMESTAMPTZ
);

CREATE INDEX idx_disputes_status ON disputes (status);
