-- Per-category commission override (P7.7/P11.8). NULL means "use the platform
-- default rate" (giggo.payments.commission-rate); a value (0..1) overrides it for
-- bookings whose skill belongs to this category.

ALTER TABLE categories ADD COLUMN commission_rate NUMERIC(6, 4);
