-- Provider weekly working hours (P2.10). One interval per day-of-week; a day
-- with no row is treated as closed. Used to guide/validate booking times (P3.3).
-- day_of_week follows java.time.DayOfWeek: 1 = Monday … 7 = Sunday.

CREATE TABLE provider_working_hours (
    id           UUID PRIMARY KEY,
    provider_id  UUID NOT NULL,
    day_of_week  INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    start_time   TIME NOT NULL,
    end_time     TIME NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_working_hours_provider_day UNIQUE (provider_id, day_of_week)
);

CREATE INDEX idx_working_hours_provider ON provider_working_hours (provider_id);
