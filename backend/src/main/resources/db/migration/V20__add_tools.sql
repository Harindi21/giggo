-- Tool Marketplace catalog (P10.1): tools/equipment for professionals.

CREATE TABLE tools (
    id           UUID PRIMARY KEY,
    slug         VARCHAR(160) NOT NULL UNIQUE,
    name         VARCHAR(200) NOT NULL,
    category     VARCHAR(60) NOT NULL,
    brand        VARCHAR(120),
    description  VARCHAR(1000) NOT NULL,
    price        NUMERIC(12, 2) NOT NULL,
    currency     VARCHAR(3) NOT NULL DEFAULT 'LKR',
    image_url    VARCHAR(500),
    available    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_tools_available ON tools (available);
CREATE INDEX idx_tools_category ON tools (category);

-- Starter catalog so the marketplace isn't empty on first run.
INSERT INTO tools (id, slug, name, category, brand, description, price)
VALUES
(gen_random_uuid(), 'cordless-drill-18v', 'Cordless Drill 18V', 'Power Tools', 'Bosch',
 'Compact 18V cordless drill with two batteries and a charger — ideal for carpentry and general repairs.', 12500.00),
(gen_random_uuid(), 'aluminium-ladder-8ft', 'Aluminium Ladder 8ft', 'Access', 'Ingco',
 'Lightweight, non-slip 8ft aluminium ladder rated for professional use.', 9800.00),
(gen_random_uuid(), 'safety-helmet-gloves-set', 'Safety Helmet & Gloves Set', 'Safety Gear', 'Karam',
 'Certified safety helmet with a pair of cut-resistant gloves. Stay protected on every job.', 2500.00),
(gen_random_uuid(), 'digital-multimeter', 'Digital Multimeter', 'Electrical', 'Fluke',
 'Auto-ranging digital multimeter for accurate voltage, current and resistance readings.', 4200.00),
(gen_random_uuid(), 'pipe-wrench-set', 'Pipe Wrench Set', 'Plumbing', 'Stanley',
 'Three-piece heavy-duty pipe wrench set for plumbing installations and repairs.', 3800.00),
(gen_random_uuid(), 'professional-cleaning-kit', 'Professional Cleaning Kit', 'Cleaning', 'GIGGO',
 'All-in-one cleaning kit: microfibre cloths, brushes and eco-friendly solutions for home services.', 6500.00);
