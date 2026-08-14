-- Append-only status event log per booking (P5.5), the source for the timeline
-- and the real-time status broadcast.

CREATE TABLE booking_status_events (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings (id) ON DELETE CASCADE,
    status     VARCHAR(20)  NOT NULL,
    at         TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_status_events_booking ON booking_status_events (booking_id, at);
