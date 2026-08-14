-- Job lifecycle audit timestamps + cancellation details (P4.3).

ALTER TABLE bookings
    ADD COLUMN accepted_at   TIMESTAMPTZ,
    ADD COLUMN started_at    TIMESTAMPTZ,
    ADD COLUMN completed_at  TIMESTAMPTZ,
    ADD COLUMN cancelled_at  TIMESTAMPTZ,
    ADD COLUMN cancelled_by  UUID REFERENCES users (id),
    ADD COLUMN cancel_reason VARCHAR(500);
