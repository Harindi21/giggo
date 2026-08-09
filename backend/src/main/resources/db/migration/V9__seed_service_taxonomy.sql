-- Production service taxonomy (categories + skills) for Sri Lanka.
-- This is real, admin-curated reference data (safe for all environments).
-- Demo *providers* are seeded separately by a dev-only CommandLineRunner.

INSERT INTO categories (name, description) VALUES
    ('Property Maintenance',   'Home and property repair, cleaning and upkeep'),
    ('Moving & Delivery',      'Moving, transport, packing and delivery services'),
    ('Life Style & Personal',  'Personal care, wellness, tutoring and lifestyle'),
    ('Business & Professional','Professional and business support services'),
    ('Vehicle Services',       'Vehicle care, repair and roadside assistance'),
    ('Other Services',         'Events, catering and miscellaneous services')
ON CONFLICT (name) DO NOTHING;

INSERT INTO skills (category_id, name)
SELECT c.id, v.skill_name
FROM categories c
JOIN (VALUES
    ('Property Maintenance',    'Plumbing'),
    ('Property Maintenance',    'Electrical Repairs'),
    ('Property Maintenance',    'Carpentry'),
    ('Property Maintenance',    'Pest Control'),
    ('Property Maintenance',    'AC & Refrigerator Repair'),
    ('Property Maintenance',    'Appliance Repair'),
    ('Property Maintenance',    'Interior Decoration'),
    ('Property Maintenance',    'House Cleaning'),
    ('Property Maintenance',    'Gardening & Landscaping'),
    ('Property Maintenance',    'Mounting & Installations'),
    ('Property Maintenance',    'Curtain & Blind Installation'),
    ('Property Maintenance',    'Drilling & Fixing'),
    ('Moving & Delivery',       'House Moving'),
    ('Moving & Delivery',       'Furniture Moving'),
    ('Moving & Delivery',       'Parcel Delivery'),
    ('Moving & Delivery',       'Packing Services'),
    ('Life Style & Personal',   'Hair & Beauty'),
    ('Life Style & Personal',   'Personal Training'),
    ('Life Style & Personal',   'Massage Therapy'),
    ('Life Style & Personal',   'Home Tutoring'),
    ('Life Style & Personal',   'Photography'),
    ('Business & Professional', 'IT Support'),
    ('Business & Professional', 'Accounting & Tax'),
    ('Business & Professional', 'Legal Consulting'),
    ('Business & Professional', 'Graphic Design'),
    ('Business & Professional', 'Digital Marketing'),
    ('Vehicle Services',        'Car Wash & Detailing'),
    ('Vehicle Services',        'Vehicle Repair'),
    ('Vehicle Services',        'Tyre & Battery'),
    ('Vehicle Services',        'Roadside Assistance'),
    ('Other Services',          'Event Planning'),
    ('Other Services',          'Catering'),
    ('Other Services',          'Security Services')
) AS v(category_name, skill_name) ON c.name = v.category_name
ON CONFLICT (category_id, name) DO NOTHING;
