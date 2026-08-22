-- Optional per-dimension ratings on reviews (P6.6): service quality,
-- punctuality and value for money (1..5). NULL = the customer skipped that
-- dimension. The overall `stars` remains the primary rating.

ALTER TABLE reviews ADD COLUMN service_rating     INTEGER;
ALTER TABLE reviews ADD COLUMN punctuality_rating INTEGER;
ALTER TABLE reviews ADD COLUMN value_rating       INTEGER;
