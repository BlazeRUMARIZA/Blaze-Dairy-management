-- Sample data for testing the Blaze Dairy Management system

-- =============================================
-- IMPORTANT: Create Users First!
-- =============================================
-- Before running this script, you MUST create users in Supabase Auth:
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Click "Add user" and create:
--    - Email: admin@blaze.com, Password: your-password
--    - Email: staff@blaze.com, Password: your-password
-- 3. After creating auth users, run this query to get their IDs:
--    SELECT id, email FROM auth.users;
-- 4. Then insert into public.users using those IDs:
--
-- INSERT INTO public.users (id, email, role, full_name, phone, status)
-- SELECT id, email, 'admin', 'Admin User', '+1234567890', 'active'
-- FROM auth.users WHERE email = 'admin@blaze.com'
-- UNION ALL
-- SELECT id, email, 'staff', 'Staff User', '+1234567891', 'active'
-- FROM auth.users WHERE email = 'staff@blaze.com';
--
-- =============================================

-- Automatically insert public.users records for existing auth.users
INSERT INTO public.users (id, email, role, full_name, phone, status)
SELECT 
  au.id,
  au.email,
  CASE 
    WHEN au.email LIKE '%admin%' THEN 'admin'::user_role
    ELSE 'staff'::user_role
  END as role,
  COALESCE(au.raw_user_meta_data->>'full_name', split_part(au.email, '@', 1)) as full_name,
  COALESCE(au.raw_user_meta_data->>'phone', '+1234567890') as phone,
  'active' as status
FROM auth.users au
WHERE NOT EXISTS (SELECT 1 FROM public.users pu WHERE pu.id = au.id)
ON CONFLICT (id) DO NOTHING;

-- Verify users were created
DO $$
DECLARE
  user_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM public.users;
  IF user_count = 0 THEN
    RAISE WARNING 'No users found in public.users! Please create users in Supabase Auth first.';
    RAISE WARNING 'Go to: Supabase Dashboard → Authentication → Users → Add user';
    RAISE WARNING 'Then re-run this script.';
  ELSE
    RAISE NOTICE '% user(s) found in public.users', user_count;
  END IF;
END $$;

-- Insert sample animals
INSERT INTO public.animals (tag_id, name, breed, sex, date_of_birth, status, acquisition_date, acquisition_type, current_weight_kg, notes) VALUES
('COW001', 'Bessie', 'Holstein', 'female', '2020-03-15', 'active', '2020-03-15', 'birth', 550.00, 'High producer'),
('COW002', 'Daisy', 'Jersey', 'female', '2019-07-22', 'active', '2019-07-22', 'purchase', 480.00, 'Good temperament'),
('COW003', 'Molly', 'Holstein', 'female', '2021-01-10', 'active', '2021-01-10', 'birth', 520.00, NULL),
('COW004', 'Bella', 'Guernsey', 'female', '2020-11-05', 'active', '2020-11-05', 'purchase', 490.00, 'High fat content'),
('COW005', 'Luna', 'Holstein', 'female', '2022-02-14', 'active', '2022-02-14', 'birth', 380.00, 'Young heifer'),
('BULL001', 'Max', 'Holstein', 'male', '2019-05-20', 'active', '2019-06-01', 'purchase', 800.00, 'Breeding bull');

-- Insert sample milk production records
INSERT INTO public.milk_productions (animal_id, production_date, shift, volume_liters, fat_percentage, snf_percentage) 
SELECT 
  a.id,
  CURRENT_DATE - (n || ' days')::interval,
  CASE WHEN random() < 0.5 THEN 'morning'::shift_type ELSE 'evening'::shift_type END,
  20 + (random() * 10),
  3.5 + (random() * 1.5),
  8.5 + (random() * 0.5)
FROM public.animals a
CROSS JOIN generate_series(0, 30) n
WHERE a.sex = 'female' AND a.status = 'active';

-- Insert sample feeds
INSERT INTO public.feeds (name, category, unit, cost_per_unit, current_stock, min_stock_threshold, description) VALUES
('Dairy Concentrate', 'concentrate', 'kg', 0.50, 1000.00, 200.00, 'High protein concentrate feed'),
('Hay', 'roughage', 'kg', 0.15, 5000.00, 500.00, 'Timothy hay'),
('Silage', 'roughage', 'kg', 0.10, 8000.00, 1000.00, 'Corn silage'),
('Mineral Mix', 'supplement', 'kg', 2.00, 100.00, 20.00, 'Essential minerals and vitamins'),
('Salt Blocks', 'supplement', 'units', 5.00, 50.00, 10.00, 'Trace mineral salt blocks');

-- Insert sample feed logs
INSERT INTO public.feed_logs (animal_id, feed_id, feeding_date, quantity, cost)
SELECT 
  a.id,
  f.id,
  CURRENT_DATE - (n || ' days')::interval,
  5 + (random() * 3),
  (5 + (random() * 3)) * f.cost_per_unit
FROM public.animals a
CROSS JOIN public.feeds f
CROSS JOIN generate_series(0, 7) n
WHERE a.status = 'active' AND f.category = 'concentrate';

-- Insert sample suppliers
INSERT INTO public.suppliers (name, contact_name, phone, email, category, status) VALUES
('Green Valley Feeds', 'John Smith', '+1234567801', 'john@greenvalley.com', 'feed', 'active'),
('Veterinary Care Plus', 'Dr. Jane Doe', '+1234567802', 'jane@vetcare.com', 'veterinary', 'active'),
('Farm Equipment Co', 'Bob Johnson', '+1234567803', 'bob@farmequip.com', 'equipment', 'active');

-- Insert sample customers
INSERT INTO public.customers (name, phone, email, tier, status) VALUES
('Local Dairy Cooperative', '+1234567810', 'orders@localdairy.com', 'wholesale', 'active'),
('Fresh Milk Store', '+1234567811', 'info@freshmilk.com', 'regular', 'active'),
('Organic Foods Market', '+1234567812', 'contact@organicfoods.com', 'premium', 'active');

-- Insert sample sales
INSERT INTO public.sales (customer_id, sale_date, item_name, quantity, unit, unit_price, total_amount, paid_amount, status)
SELECT 
  c.id,
  CURRENT_DATE - (n || ' days')::interval,
  'Milk',
  100 + (random() * 100),
  'liters',
  0.50,
  (100 + (random() * 100)) * 0.50,
  (100 + (random() * 100)) * 0.50,
  'paid'
FROM public.customers c
CROSS JOIN generate_series(0, 30) n;

-- Insert sample expenses
INSERT INTO public.expenses (vendor_name, supplier_id, category, expense_date, amount, description)
SELECT 
  s.name,
  s.id,
  CASE s.category
    WHEN 'feed' THEN 'feed'::expense_category
    WHEN 'veterinary' THEN 'veterinary'::expense_category
    ELSE 'equipment'::expense_category
  END,
  CURRENT_DATE - (n || ' days')::interval,
  100 + (random() * 400),
  'Regular ' || s.category || ' purchase'
FROM public.suppliers s
CROSS JOIN generate_series(0, 30, 7) n;

-- Insert sample health records
INSERT INTO public.health_records (animal_id, event_date, event_type, diagnosis, treatment, medication, cost, notes)
SELECT 
  a.id,
  CURRENT_DATE - ((random() * 90)::int || ' days')::interval,
  (ARRAY['vaccination'::health_event_type, 'checkup'::health_event_type, 'treatment'::health_event_type])[floor(random() * 3 + 1)],
  'Routine health check',
  'Preventive care',
  CASE WHEN random() < 0.5 THEN 'Vaccine XYZ' ELSE 'Antibiotic ABC' END,
  25 + (random() * 75),
  'Regular veterinary visit'
FROM public.animals a
WHERE a.status = 'active';

-- Insert sample inventory items
INSERT INTO public.inventory_items (name, sku, category, unit, quantity, min_threshold, unit_cost, location) VALUES
('Milking Machine Filters', 'MMF-001', 'supplies', 'pieces', 50, 10, 2.50, 'Storage Room A'),
('Cleaning Solution', 'CS-001', 'supplies', 'liters', 100, 20, 5.00, 'Storage Room B'),
('Udder Cream', 'UC-001', 'consumables', 'tubes', 30, 5, 8.00, 'Medical Cabinet'),
('Gloves', 'GLV-001', 'supplies', 'boxes', 20, 5, 15.00, 'Storage Room A'),
('Thermometers', 'THERM-001', 'equipment', 'units', 10, 2, 25.00, 'Medical Cabinet');

-- Insert sample tasks
INSERT INTO public.tasks (title, description, due_date, priority, status)
SELECT 
  'Check animal ' || a.tag_id,
  'Routine health inspection for ' || a.name,
  CURRENT_DATE + ((random() * 14)::int || ' days')::interval,
  (ARRAY['low', 'medium', 'high'])[floor(random() * 3 + 1)],
  (ARRAY['pending'::task_status, 'in_progress'::task_status])[floor(random() * 2 + 1)]
FROM public.animals a
WHERE a.status = 'active'
LIMIT 10;

-- Insert sample activity logs
INSERT INTO public.activity_logs (action, entity_type, entity_id, metadata)
SELECT 
  'created',
  'animal',
  a.id,
  jsonb_build_object('tag_id', a.tag_id, 'name', a.name)
FROM public.animals a
LIMIT 20;

COMMIT;
