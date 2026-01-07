-- =============================================
-- Blaze Dairy Management - RLS Policies
-- Migration 002: Row Level Security
-- =============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.milk_productions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feeds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feed_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;

-- =============================================
-- Helper Functions
-- =============================================

-- Get current user's role
CREATE OR REPLACE FUNCTION public.user_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- =============================================
-- Users Table Policies
-- =============================================

-- Users can read their own profile
CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

-- Admins can view all users
CREATE POLICY "Admins can view all users"
  ON public.users FOR SELECT
  USING (public.is_admin());

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

-- Only admins can insert/delete users
CREATE POLICY "Admins can insert users"
  ON public.users FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete users"
  ON public.users FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Animals Table Policies
-- =============================================

-- Everyone can read animals
CREATE POLICY "All users can view animals"
  ON public.animals FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- Authenticated users can create animals
CREATE POLICY "Authenticated users can create animals"
  ON public.animals FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Users can update animals (admins can update all, staff can update specific fields)
CREATE POLICY "Users can update animals"
  ON public.animals FOR UPDATE
  USING (auth.uid() IS NOT NULL);

-- Only admins can delete animals
CREATE POLICY "Admins can delete animals"
  ON public.animals FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Milk Productions Policies
-- =============================================

CREATE POLICY "All users can view milk productions"
  ON public.milk_productions FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create milk productions"
  ON public.milk_productions FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update milk productions"
  ON public.milk_productions FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete milk productions"
  ON public.milk_productions FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Feeds Policies
-- =============================================

CREATE POLICY "All users can view feeds"
  ON public.feeds FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create feeds"
  ON public.feeds FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update feeds"
  ON public.feeds FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete feeds"
  ON public.feeds FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Feed Logs Policies
-- =============================================

CREATE POLICY "All users can view feed logs"
  ON public.feed_logs FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create feed logs"
  ON public.feed_logs FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update feed logs"
  ON public.feed_logs FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete feed logs"
  ON public.feed_logs FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Health Records Policies
-- =============================================

CREATE POLICY "All users can view health records"
  ON public.health_records FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create health records"
  ON public.health_records FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update health records"
  ON public.health_records FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete health records"
  ON public.health_records FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Suppliers Policies
-- =============================================

CREATE POLICY "All users can view suppliers"
  ON public.suppliers FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create suppliers"
  ON public.suppliers FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update suppliers"
  ON public.suppliers FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete suppliers"
  ON public.suppliers FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Customers Policies
-- =============================================

CREATE POLICY "All users can view customers"
  ON public.customers FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create customers"
  ON public.customers FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update customers"
  ON public.customers FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete customers"
  ON public.customers FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Sales Policies
-- =============================================

CREATE POLICY "All users can view sales"
  ON public.sales FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create sales"
  ON public.sales FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update sales"
  ON public.sales FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete sales"
  ON public.sales FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Expenses Policies
-- =============================================

-- Staff can view expenses, admins can view all
CREATE POLICY "Users can view expenses"
  ON public.expenses FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create expenses"
  ON public.expenses FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update expenses"
  ON public.expenses FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete expenses"
  ON public.expenses FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Inventory Policies
-- =============================================

CREATE POLICY "All users can view inventory"
  ON public.inventory_items FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can create inventory items"
  ON public.inventory_items FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update inventory"
  ON public.inventory_items FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can delete inventory"
  ON public.inventory_items FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Tasks Policies
-- =============================================

-- Users can see tasks assigned to them or created by them, admins see all
CREATE POLICY "Users can view relevant tasks"
  ON public.tasks FOR SELECT
  USING (
    public.is_admin() OR 
    assignee_id = auth.uid() OR 
    created_by = auth.uid()
  );

CREATE POLICY "Users can create tasks"
  ON public.tasks FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update assigned tasks"
  ON public.tasks FOR UPDATE
  USING (
    public.is_admin() OR 
    assignee_id = auth.uid() OR 
    created_by = auth.uid()
  );

CREATE POLICY "Admins can delete tasks"
  ON public.tasks FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Activity Logs Policies
-- =============================================

-- Users can see their own activity, admins see all
CREATE POLICY "Users can view relevant activity logs"
  ON public.activity_logs FOR SELECT
  USING (
    public.is_admin() OR 
    user_id = auth.uid()
  );

-- All authenticated users can insert activity logs
CREATE POLICY "Users can create activity logs"
  ON public.activity_logs FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Only admins can delete logs
CREATE POLICY "Admins can delete activity logs"
  ON public.activity_logs FOR DELETE
  USING (public.is_admin());

-- =============================================
-- Attachments Policies
-- =============================================

CREATE POLICY "All users can view attachments"
  ON public.attachments FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can upload attachments"
  ON public.attachments FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can delete own attachments"
  ON public.attachments FOR DELETE
  USING (
    public.is_admin() OR 
    uploaded_by = auth.uid()
  );

-- =============================================
-- Storage Policies
-- =============================================

-- Create storage buckets (run these in Supabase dashboard or via client)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('attachments', 'attachments', false);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('animal_photos', 'animal_photos', false);

-- Storage policies for attachments bucket
CREATE POLICY "Authenticated users can upload to attachments"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'attachments' AND 
    auth.role() = 'authenticated'
  );

CREATE POLICY "Authenticated users can read attachments"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'attachments' AND 
    auth.role() = 'authenticated'
  );

CREATE POLICY "Users can delete own attachments"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'attachments' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Storage policies for animal_photos bucket
CREATE POLICY "Authenticated users can upload animal photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'animal_photos' AND 
    auth.role() = 'authenticated'
  );

CREATE POLICY "Authenticated users can read animal photos"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'animal_photos' AND 
    auth.role() = 'authenticated'
  );

CREATE POLICY "Users can update animal photos"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'animal_photos' AND 
    auth.role() = 'authenticated'
  );

CREATE POLICY "Users can delete animal photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'animal_photos' AND 
    auth.role() = 'authenticated'
  );
