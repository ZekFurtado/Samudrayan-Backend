-- =============================================================================
-- Seed: Dummy Restaurant Data (Konkan Region)
-- Run order: after create-restaurant-tables.sql
-- Safe to re-run: all inserts use ON CONFLICT DO NOTHING
-- Each statement runs in autocommit — a single failure won't block the rest.
-- =============================================================================

-- Clear any aborted transaction left over from a previous failed run
ROLLBACK;

-- ---------------------------------------------------------------------------
-- 1. Dummy restaurant-owner users
--    Using deterministic firebase_uid values so re-runs are idempotent
-- ---------------------------------------------------------------------------
INSERT INTO users (id, firebase_uid, full_name, email, phone, role, district, taluka, is_verified)
VALUES
    (
        '11111111-0000-0000-0000-000000000001',
        'dummy_resto_owner_001',
        'Ramesh Sawant',
        'ramesh.sawant@example.com',
        '9823100001',
        'restaurant-owner',
        'Sindhudurg',
        'Malvan',
        TRUE
    ),
    (
        '11111111-0000-0000-0000-000000000002',
        'dummy_resto_owner_002',
        'Sunita Naik',
        'sunita.naik@example.com',
        '9823100002',
        'restaurant-owner',
        'Sindhudurg',
        'Devgad',
        TRUE
    ),
    (
        '11111111-0000-0000-0000-000000000003',
        'dummy_resto_owner_003',
        'Pravin Desai',
        'pravin.desai@example.com',
        '9823100003',
        'restaurant-owner',
        'Ratnagiri',
        'Ratnagiri',
        TRUE
    )
ON CONFLICT (email) DO NOTHING;

-- Dummy tourist user for reservations
INSERT INTO users (id, firebase_uid, full_name, email, phone, role, district, taluka, is_verified)
VALUES
    (
        '11111111-0000-0000-0000-000000000010',
        'dummy_tourist_001',
        'Ankit Sharma',
        'ankit.sharma@example.com',
        '9483625174',
        'tourist',
        'Sindhudurg',
        'Malvan',
        TRUE
    ),
    (
        '11111111-0000-0000-0000-000000000011',
        'dummy_tourist_002',
        'Priya Kulkarni',
        'priya.kulkarni@example.com',
        '9876543211',
        'tourist',
        'Ratnagiri',
        'Dapoli',
        TRUE
    )
ON CONFLICT (email) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2. Restaurants
-- ---------------------------------------------------------------------------
INSERT INTO restaurants (
    id, owner_id, name, description, cuisine_type,
    contact_phone, contact_email,
    address, district, taluka,
    location_lat, location_lng,
    opening_hours, average_cost_for_two, seating_capacity,
    amenities, photos,
    status, is_verified, rating, total_reviews
)
VALUES
    (
        'aaaaaaaa-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000001',
        'Malvan Seafood House',
        'Authentic Malvani coastal cuisine featuring fresh catch from the Arabian Sea. Known for our spicy fish curry and Malvani thali.',
        'Malvani Seafood',
        '9823200001',
        'info@malvanseafoodhouse.com',
        'Near Sindhudurg Fort Jetty, Malvan Town',
        'Sindhudurg',
        'Malvan',
        16.0590,
        73.4678,
        '{"monday":{"open":"11:00","close":"22:00"},"tuesday":{"open":"11:00","close":"22:00"},"wednesday":{"open":"11:00","close":"22:00"},"thursday":{"open":"11:00","close":"22:00"},"friday":{"open":"11:00","close":"23:00"},"saturday":{"open":"10:00","close":"23:00"},"sunday":{"open":"10:00","close":"22:00"}}',
        800,
        60,
        ARRAY['Sea View', 'AC', 'Parking', 'Family Section', 'Live Cooking'],
        ARRAY['https://example.com/photos/malvan-seafood-1.jpg', 'https://example.com/photos/malvan-seafood-2.jpg'],
        'active',
        TRUE,
        4.5,
        128
    ),
    (
        'aaaaaaaa-0000-0000-0000-000000000002',
        '11111111-0000-0000-0000-000000000001',
        'Kokan Tadka',
        'A family restaurant serving traditional Konkan vegetarian and non-vegetarian dishes. Famous for our sol kadhi and amboli breakfast.',
        'Konkani',
        '9823200002',
        'kokantadka@example.com',
        'Main Bazaar Road, Malvan',
        'Sindhudurg',
        'Malvan',
        16.0622,
        73.4700,
        '{"monday":{"open":"08:00","close":"21:00"},"tuesday":{"open":"08:00","close":"21:00"},"wednesday":{"open":"08:00","close":"21:00"},"thursday":{"open":"08:00","close":"21:00"},"friday":{"open":"08:00","close":"21:00"},"saturday":{"open":"08:00","close":"22:00"},"sunday":{"open":"08:00","close":"22:00"}}',
        400,
        40,
        ARRAY['WiFi', 'Takeaway', 'Home Delivery'],
        ARRAY['https://example.com/photos/kokan-tadka-1.jpg'],
        'active',
        TRUE,
        4.2,
        75
    ),
    (
        'aaaaaaaa-0000-0000-0000-000000000003',
        '11111111-0000-0000-0000-000000000002',
        'Devgad Alphonso Garden Cafe',
        'A breezy garden cafe set in an alphonso mango orchard. Seasonal Alphonso mango desserts, fresh juices, and light Konkani snacks.',
        'Cafe & Snacks',
        '9823200003',
        'alphonsocafe@example.com',
        'Mango Orchard Road, Devgad',
        'Sindhudurg',
        'Devgad',
        16.3800,
        73.3700,
        '{"monday":{"open":"09:00","close":"20:00"},"tuesday":{"open":"09:00","close":"20:00"},"wednesday":{"open":"09:00","close":"20:00"},"thursday":{"open":"09:00","close":"20:00"},"friday":{"open":"09:00","close":"20:00"},"saturday":{"open":"08:00","close":"21:00"},"sunday":{"open":"08:00","close":"21:00"}}',
        350,
        30,
        ARRAY['Garden Seating', 'Organic Produce', 'Takeaway', 'Kids Area'],
        ARRAY['https://example.com/photos/devgad-cafe-1.jpg', 'https://example.com/photos/devgad-cafe-2.jpg'],
        'active',
        TRUE,
        4.7,
        203
    ),
    (
        'aaaaaaaa-0000-0000-0000-000000000004',
        '11111111-0000-0000-0000-000000000003',
        'Ratnagiri Bay View',
        'Multi-cuisine restaurant with a stunning view of Ratnagiri bay. Specialises in Konkani seafood platters and coastal thali.',
        'Multi-Cuisine & Seafood',
        '9823200004',
        'bayview@example.com',
        'Bhatye Beach Road, Ratnagiri',
        'Ratnagiri',
        'Ratnagiri',
        16.9900,
        73.3100,
        '{"monday":{"open":"12:00","close":"22:00"},"tuesday":{"open":"12:00","close":"22:00"},"wednesday":{"open":"12:00","close":"22:00"},"thursday":{"open":"12:00","close":"22:00"},"friday":{"open":"12:00","close":"23:00"},"saturday":{"open":"11:00","close":"23:00"},"sunday":{"open":"11:00","close":"22:00"}}',
        1200,
        80,
        ARRAY['Sea View', 'AC', 'Bar', 'Parking', 'Private Dining', 'Live Music on Weekends'],
        ARRAY['https://example.com/photos/bayview-1.jpg', 'https://example.com/photos/bayview-2.jpg', 'https://example.com/photos/bayview-3.jpg'],
        'active',
        TRUE,
        4.3,
        311
    ),
    (
        'aaaaaaaa-0000-0000-0000-000000000005',
        '11111111-0000-0000-0000-000000000003',
        'Fisherman Wharf Ratnagiri',
        'Rustic waterfront dining experience. Fresh fish bought directly from local fishermen each morning. Known for surmai fry and bombil fry.',
        'Coastal Seafood',
        '9823200005',
        NULL,
        'Harbour Area, Ratnagiri Port',
        'Ratnagiri',
        'Ratnagiri',
        17.0000,
        73.3050,
        '{"tuesday":{"open":"12:00","close":"20:00"},"wednesday":{"open":"12:00","close":"20:00"},"thursday":{"open":"12:00","close":"20:00"},"friday":{"open":"12:00","close":"21:00"},"saturday":{"open":"11:00","close":"21:00"},"sunday":{"open":"11:00","close":"20:00"}}',
        600,
        35,
        ARRAY['Waterfront', 'Outdoor Seating', 'Catch-of-the-Day'],
        ARRAY['https://example.com/photos/fisherman-wharf-1.jpg'],
        'pending-verification',
        FALSE,
        0.0,
        0
    )
ON CONFLICT (owner_id, name) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 3. Menu items
-- ---------------------------------------------------------------------------

-- Malvan Seafood House menu
INSERT INTO restaurant_menu (
    id, restaurant_id, category, item_name, description,
    price, is_vegetarian, is_vegan, contains_gluten,
    spice_level, preparation_time, is_available
)
VALUES
    -- Starters
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Starters', 'Tisrya Masala', 'Malvani spiced clams tossed with onion, coconut, and coastal masala', 220, FALSE, FALSE, FALSE, 'spicy', 15, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Starters', 'Kolambi Bhajji', 'Crispy batter-fried prawns with kokum chutney', 280, FALSE, FALSE, TRUE, 'medium', 12, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Starters', 'Sol Kadhi', 'Refreshing kokum and coconut milk drink', 60, TRUE, TRUE, FALSE, 'mild', 5, TRUE),
    -- Main Course
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Main Course', 'Malvani Fish Curry', 'Traditional red curry with surmai (kingfish) in coconut-based gravy', 350, FALSE, FALSE, FALSE, 'spicy', 25, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Main Course', 'Bombil Fry', 'Crispy fried Bombay duck marinated in Malvani masala', 180, FALSE, FALSE, TRUE, 'spicy', 15, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Main Course', 'Malvani Chicken Rassa', 'Fiery Malvani chicken gravy with freshly ground spice blend', 320, FALSE, FALSE, FALSE, 'very-spicy', 30, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Main Course', 'Veg Malvani Thali', 'Complete Malvani thali with rice, dal, sabzi, papad, and pickle', 250, TRUE, FALSE, FALSE, 'medium', 15, TRUE),
    -- Breads & Rice
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Breads & Rice', 'Steamed Rice', 'Locally grown rice', 60, TRUE, TRUE, FALSE, 'mild', 10, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Breads & Rice', 'Bhakri', 'Traditional jowar flatbread', 40, TRUE, TRUE, FALSE, 'mild', 10, TRUE),
    -- Desserts
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Desserts', 'Ukdiche Modak', 'Steamed sweet dumplings stuffed with coconut and jaggery', 120, TRUE, FALSE, FALSE, 'mild', 20, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000001', 'Desserts', 'Coconut Jaggery Ice Cream', 'House-made ice cream with fresh coconut and coastal jaggery', 90, TRUE, FALSE, FALSE, 'mild', 5, TRUE),

    -- Kokan Tadka menu
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000002', 'Breakfast', 'Amboli', 'Soft fermented rice pancakes served with coconut chutney and sambar', 80, TRUE, TRUE, FALSE, 'mild', 10, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000002', 'Breakfast', 'Ghavan', 'Rice flour crepes — light and crispy, a Konkan breakfast staple', 70, TRUE, TRUE, FALSE, 'mild', 10, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000002', 'Breakfast', 'Pohe', 'Flattened rice tempered with mustard, turmeric, and peanuts', 60, TRUE, TRUE, FALSE, 'mild', 8, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000002', 'Main Course', 'Mackerel Curry Rice', 'Bangda (mackerel) in tangy kokum curry served with steamed rice', 200, FALSE, FALSE, FALSE, 'spicy', 20, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000002', 'Main Course', 'Varan Bhaat', 'Simple comfort food — toor dal with steamed rice and a dollop of ghee', 120, TRUE, FALSE, FALSE, 'mild', 15, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000002', 'Beverages', 'Fresh Kokum Sherbet', 'Cooling kokum drink with a pinch of cumin and salt', 50, TRUE, TRUE, FALSE, 'mild', 3, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000002', 'Beverages', 'Filter Coffee', 'South Indian style drip coffee with buffalo milk', 40, TRUE, FALSE, FALSE, 'mild', 5, TRUE),

    -- Devgad Alphonso Garden Cafe menu
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000003', 'Drinks & Juices', 'Alphonso Mango Milkshake', 'Fresh Devgad Alphonso mango blended with chilled milk (seasonal: Mar-Jun)', 120, TRUE, FALSE, FALSE, 'mild', 5, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000003', 'Drinks & Juices', 'Raw Mango Panna', 'Chilled raw mango drink with mint and rock salt', 80, TRUE, TRUE, FALSE, 'mild', 5, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000003', 'Snacks', 'Mango Salsa Sandwich', 'Whole wheat sandwich with fresh mango salsa, cucumber, and cream cheese', 130, TRUE, FALSE, TRUE, 'mild', 10, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000003', 'Desserts', 'Aamras', 'Freshly squeezed Alphonso mango pulp served with puri (seasonal)', 150, TRUE, FALSE, TRUE, 'mild', 10, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000003', 'Desserts', 'Mango Cheesecake', 'House-baked cheesecake with Alphonso mango topping', 180, TRUE, FALSE, TRUE, 'mild', 5, TRUE),

    -- Ratnagiri Bay View menu
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000004', 'Starters', 'Prawn Koliwada', 'Crispy marinated prawns in a tangy Koliwada spice coat', 320, FALSE, FALSE, TRUE, 'medium', 15, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000004', 'Starters', 'Crab Butter Garlic', 'Fresh mud crab sautéed in butter and garlic — a chef special', 480, FALSE, FALSE, FALSE, 'medium', 20, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000004', 'Starters', 'Paneer Tikka', 'Tandoor-roasted cottage cheese with bell peppers and mint chutney', 240, TRUE, FALSE, FALSE, 'mild', 20, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000004', 'Main Course', 'Coastal Seafood Platter', 'A mixed platter of grilled surmai, bombil fry, tisrya, and prawns', 890, FALSE, FALSE, TRUE, 'medium', 35, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000004', 'Main Course', 'Lobster Thermidor', 'Fresh Ratnagiri lobster baked in a creamy white wine sauce', 1400, FALSE, FALSE, FALSE, 'mild', 40, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000004', 'Main Course', 'Dal Tadka with Naan', 'Yellow dal tempered with ghee and spices, served with fresh naan', 280, TRUE, FALSE, TRUE, 'medium', 15, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000004', 'Desserts', 'Alphonso Panna Cotta', 'Silky Italian dessert with Ratnagiri Alphonso mango coulis', 220, TRUE, FALSE, FALSE, 'mild', 5, TRUE),

    -- Fisherman Wharf menu
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000005', 'Catch of the Day', 'Surmai Fry', 'King mackerel shallow fried in Malvani masala — market-fresh daily', 280, FALSE, FALSE, TRUE, 'spicy', 15, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000005', 'Catch of the Day', 'Bombil Fry', 'Bombay duck fried till golden and crispy', 160, FALSE, FALSE, TRUE, 'medium', 12, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000005', 'Catch of the Day', 'Rawas Curry', 'Indian salmon in a light coconut-tomato curry', 310, FALSE, FALSE, FALSE, 'medium', 25, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000005', 'Sides', 'Steamed Rice', 'Plain steamed rice', 50, TRUE, TRUE, FALSE, 'mild', 10, TRUE),
    (gen_random_uuid(), 'aaaaaaaa-0000-0000-0000-000000000005', 'Beverages', 'Sol Kadhi', 'Kokum and coconut milk digestive drink', 50, TRUE, TRUE, FALSE, 'mild', 5, TRUE)

ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------------
-- 4. Time slots
-- ---------------------------------------------------------------------------
INSERT INTO restaurant_time_slots (
    restaurant_id, day_of_week, start_time, end_time, max_capacity, slot_duration, is_active
)
SELECT
    r.id,
    d.day,
    s.slot_start::TIME,
    s.slot_end::TIME,
    r.seating_capacity,
    90,
    TRUE
FROM
    (SELECT id, seating_capacity FROM restaurants WHERE id IN (
        'aaaaaaaa-0000-0000-0000-000000000001',
        'aaaaaaaa-0000-0000-0000-000000000004'
    )) r
    CROSS JOIN (VALUES (1),(2),(3),(4),(5),(6),(0)) AS d(day)
    CROSS JOIN (VALUES ('12:00','13:30'), ('13:30','15:00'), ('19:00','20:30'), ('20:30','22:00')) AS s(slot_start, slot_end)
ON CONFLICT (restaurant_id, day_of_week, start_time) DO NOTHING;

-- Cafe with simpler daytime-only slots
INSERT INTO restaurant_time_slots (
    restaurant_id, day_of_week, start_time, end_time, max_capacity, slot_duration, is_active
)
SELECT
    'aaaaaaaa-0000-0000-0000-000000000003',
    d.day,
    s.slot_start::TIME,
    s.slot_end::TIME,
    30,
    60,
    TRUE
FROM
    (VALUES (1),(2),(3),(4),(5),(6),(0)) AS d(day)
    CROSS JOIN (VALUES ('09:00','10:00'), ('10:00','11:00'), ('11:00','12:00'), ('15:00','16:00'), ('16:00','17:00')) AS s(slot_start, slot_end)
ON CONFLICT (restaurant_id, day_of_week, start_time) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 5. Reservations
-- ---------------------------------------------------------------------------
INSERT INTO restaurant_reservations (
    id, restaurant_id, customer_id,
    customer_name, customer_phone, customer_email,
    reservation_date, reservation_time, party_size,
    special_requests, table_preference, status,
    confirmed_at, created_at, updated_at
)
VALUES
    (
        gen_random_uuid(),
        'aaaaaaaa-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000010',
        'Ankit Sharma', '9876543210', 'ankit.sharma@example.com',
        CURRENT_DATE + INTERVAL '3 days', '19:30', 4,
        'Prefer sea-facing table. Allergic to shellfish — no tisrya please.',
        'sea-facing',
        'confirmed',
        NOW() - INTERVAL '1 hour',
        NOW() - INTERVAL '2 hours',
        NOW() - INTERVAL '1 hour'
    ),
    (
        gen_random_uuid(),
        'aaaaaaaa-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000011',
        'Priya Kulkarni', '9876543211', 'priya.kulkarni@example.com',
        CURRENT_DATE + INTERVAL '1 day', '13:00', 2,
        NULL,
        'corner',
        'pending',
        NULL,
        NOW() - INTERVAL '30 minutes',
        NOW() - INTERVAL '30 minutes'
    ),
    (
        gen_random_uuid(),
        'aaaaaaaa-0000-0000-0000-000000000004',
        '11111111-0000-0000-0000-000000000010',
        'Ankit Sharma', '9876543210', 'ankit.sharma@example.com',
        CURRENT_DATE - INTERVAL '5 days', '20:00', 6,
        'Anniversary dinner — please arrange a small cake if possible.',
        'window',
        'completed',
        NOW() - INTERVAL '6 days',
        NOW() - INTERVAL '7 days',
        NOW() - INTERVAL '5 days'
    ),
    (
        gen_random_uuid(),
        'aaaaaaaa-0000-0000-0000-000000000004',
        '11111111-0000-0000-0000-000000000011',
        'Priya Kulkarni', '9876543211', 'priya.kulkarni@example.com',
        CURRENT_DATE - INTERVAL '2 days', '13:30', 3,
        NULL,
        NULL,
        'cancelled',
        NULL,
        NOW() - INTERVAL '4 days',
        NOW() - INTERVAL '2 days'
    ),
    (
        gen_random_uuid(),
        'aaaaaaaa-0000-0000-0000-000000000003',
        '11111111-0000-0000-0000-000000000011',
        'Priya Kulkarni', '9876543211', 'priya.kulkarni@example.com',
        CURRENT_DATE + INTERVAL '7 days', '10:00', 2,
        'Celebrating mango season — first visit!',
        'garden',
        'pending',
        NULL,
        NOW(),
        NOW()
    )
ON CONFLICT DO NOTHING;

-- Update cancelled_at for cancelled reservation
UPDATE restaurant_reservations
SET cancelled_at = NOW() - INTERVAL '2 days',
    cancellation_reason = 'Change of travel plans'
WHERE restaurant_id = 'aaaaaaaa-0000-0000-0000-000000000004'
  AND status = 'cancelled'
  AND cancelled_at IS NULL;

-- ---------------------------------------------------------------------------
-- Quick sanity check (optional — run separately to verify)
-- ---------------------------------------------------------------------------
-- SELECT 'users'                  AS table_name, COUNT(*) FROM users                   WHERE firebase_uid LIKE 'dummy_%'
-- UNION ALL
-- SELECT 'restaurants',            COUNT(*) FROM restaurants            WHERE id LIKE 'aaaaaaaa-%'
-- UNION ALL
-- SELECT 'restaurant_menu',        COUNT(*) FROM restaurant_menu        WHERE restaurant_id LIKE 'aaaaaaaa-%'
-- UNION ALL
-- SELECT 'restaurant_time_slots',  COUNT(*) FROM restaurant_time_slots  WHERE restaurant_id LIKE 'aaaaaaaa-%'
-- UNION ALL
-- SELECT 'restaurant_reservations',COUNT(*) FROM restaurant_reservations WHERE restaurant_id LIKE 'aaaaaaaa-%';
