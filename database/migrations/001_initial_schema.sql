-- =============================================
-- Blaze Dairy Management - Database Schema
-- Migration 001: Initial Setup
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types/enums
CREATE TYPE user_role AS ENUM ('admin', 'staff');
CREATE TYPE animal_status AS ENUM ('active', 'sold', 'deceased', 'transferred');
CREATE TYPE animal_sex AS ENUM ('male', 'female');
CREATE TYPE shift_type AS ENUM ('morning', 'evening', 'night');
CREATE TYPE health_event_type AS ENUM ('vaccination', 'treatment', 'checkup', 'surgery', 'injury');
CREATE TYPE sale_status AS ENUM ('pending', 'paid', 'partial', 'cancelled');
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');
CREATE TYPE expense_category AS ENUM ('feed', 'veterinary', 'labor', 'equipment', 'utilities', 'maintenance', 'supplies', 'other');

-- =============================================
-- Users & Authentication
-- =============================================

-- Extends Supabase auth.users
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  role user_role NOT NULL DEFAULT 'staff',
  full_name TEXT,
  phone TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.users IS 'Extended user profile information';

-- =============================================
-- Livestock Management
-- =============================================

CREATE TABLE public.animals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tag_id TEXT UNIQUE NOT NULL,
  name TEXT,
  breed TEXT,
  sex animal_sex NOT NULL,
  date_of_birth DATE,
  status animal_status NOT NULL DEFAULT 'active',
  acquisition_date DATE NOT NULL DEFAULT CURRENT_DATE,
  acquisition_type TEXT, -- birth, purchase, transfer
  mother_id UUID REFERENCES public.animals(id) ON DELETE SET NULL,
  father_id UUID REFERENCES public.animals(id) ON DELETE SET NULL,
  current_weight_kg DECIMAL(10,2),
  purchase_price DECIMAL(10,2),
  notes TEXT,
  photo_url TEXT,
  created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_animals_tag_id ON public.animals(tag_id);
CREATE INDEX idx_animals_status ON public.animals(status);
CREATE INDEX idx_animals_created_at ON public.animals(created_at DESC);

COMMENT ON TABLE public.animals IS 'Livestock registry with lifecycle tracking';

-- =============================================
-- Milk Production
-- =============================================

CREATE TABLE public.milk_productions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  animal_id UUID REFERENCES public.animals(id) ON DELETE CASCADE,
  production_date DATE NOT NULL DEFAULT CURRENT_DATE,
  shift shift_type NOT NULL,
  volume_liters DECIMAL(10,2) NOT NULL CHECK (volume_liters > 0),
  fat_percentage DECIMAL(5,2) CHECK (fat_percentage >= 0 AND fat_percentage <= 100),
  snf_percentage DECIMAL(5,2) CHECK (snf_percentage >= 0 AND snf_percentage <= 100),
  temperature_celsius DECIMAL(5,2),
  notes TEXT,
  recorded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(animal_id, production_date, shift)
);

CREATE INDEX idx_milk_production_date ON public.milk_productions(production_date DESC);
CREATE INDEX idx_milk_production_animal ON public.milk_productions(animal_id);

COMMENT ON TABLE public.milk_productions IS 'Daily milk production records per animal and shift';

-- =============================================
-- Suppliers (must come before feeds that reference it)
-- =============================================

CREATE TABLE public.suppliers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  contact_name TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  category TEXT, -- feed, equipment, veterinary, etc.
  notes TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_suppliers_name ON public.suppliers(name);

COMMENT ON TABLE public.suppliers IS 'Supplier and vendor directory';

-- =============================================
-- Customers
-- =============================================

CREATE TABLE public.customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  address TEXT,
  tier TEXT, -- regular, premium, wholesale
  credit_limit DECIMAL(10,2) DEFAULT 0,
  current_balance DECIMAL(10,2) DEFAULT 0,
  notes TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_customers_name ON public.customers(name);

COMMENT ON TABLE public.customers IS 'Customer directory for sales';

-- =============================================
-- Feed Management
-- =============================================

CREATE TABLE public.feeds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  category TEXT, -- concentrate, roughage, mineral, supplement
  unit TEXT NOT NULL DEFAULT 'kg', -- kg, liters, bags
  cost_per_unit DECIMAL(10,2),
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
  current_stock DECIMAL(10,2) DEFAULT 0,
  min_stock_threshold DECIMAL(10,2) DEFAULT 0,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_feeds_name ON public.feeds(name);

CREATE TABLE public.feed_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  animal_id UUID REFERENCES public.animals(id) ON DELETE CASCADE,
  feed_id UUID NOT NULL REFERENCES public.feeds(id) ON DELETE CASCADE,
  feeding_date DATE NOT NULL DEFAULT CURRENT_DATE,
  quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
  cost DECIMAL(10,2),
  notes TEXT,
  recorded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_feed_logs_date ON public.feed_logs(feeding_date DESC);
CREATE INDEX idx_feed_logs_animal ON public.feed_logs(animal_id);
CREATE INDEX idx_feed_logs_feed ON public.feed_logs(feed_id);

COMMENT ON TABLE public.feeds IS 'Feed catalog and inventory';
COMMENT ON TABLE public.feed_logs IS 'Feed consumption records';

-- =============================================
-- Health Records
-- =============================================

CREATE TABLE public.health_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  animal_id UUID NOT NULL REFERENCES public.animals(id) ON DELETE CASCADE,
  event_date DATE NOT NULL DEFAULT CURRENT_DATE,
  event_type health_event_type NOT NULL,
  diagnosis TEXT,
  treatment TEXT,
  medication TEXT,
  dosage TEXT,
  veterinarian_name TEXT,
  next_visit_date DATE,
  cost DECIMAL(10,2),
  notes TEXT,
  attachments JSONB, -- Array of storage URLs
  recorded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_health_records_animal ON public.health_records(animal_id);
CREATE INDEX idx_health_records_date ON public.health_records(event_date DESC);
CREATE INDEX idx_health_records_type ON public.health_records(event_type);
CREATE INDEX idx_health_next_visit ON public.health_records(next_visit_date) WHERE next_visit_date IS NOT NULL;

COMMENT ON TABLE public.health_records IS 'Animal health events and veterinary records';

-- =============================================
-- Sales
-- =============================================

CREATE TABLE public.sales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
  sale_date DATE NOT NULL DEFAULT CURRENT_DATE,
  item_name TEXT NOT NULL, -- milk, animal, product
  quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
  unit TEXT NOT NULL DEFAULT 'liters',
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  total_amount DECIMAL(10,2) NOT NULL,
  paid_amount DECIMAL(10,2) DEFAULT 0,
  status sale_status DEFAULT 'pending',
  payment_method TEXT,
  invoice_number TEXT,
  notes TEXT,
  recorded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sales_date ON public.sales(sale_date DESC);
CREATE INDEX idx_sales_customer ON public.sales(customer_id);
CREATE INDEX idx_sales_status ON public.sales(status);

COMMENT ON TABLE public.sales IS 'Sales transactions and invoices';

-- =============================================
-- Expenses
-- =============================================

CREATE TABLE public.expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_name TEXT,
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
  category expense_category NOT NULL,
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  description TEXT,
  payment_method TEXT,
  receipt_url TEXT,
  notes TEXT,
  recorded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_expenses_date ON public.expenses(expense_date DESC);
CREATE INDEX idx_expenses_category ON public.expenses(category);

COMMENT ON TABLE public.expenses IS 'Farm expenses and costs';

-- =============================================
-- Inventory
-- =============================================

CREATE TABLE public.inventory_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  sku TEXT UNIQUE,
  category TEXT, -- equipment, supplies, consumables
  unit TEXT NOT NULL,
  quantity DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  min_threshold DECIMAL(10,2) DEFAULT 0,
  unit_cost DECIMAL(10,2),
  location TEXT,
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
  notes TEXT,
  last_restocked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_inventory_name ON public.inventory_items(name);
CREATE INDEX idx_inventory_low_stock ON public.inventory_items(quantity) WHERE quantity <= min_threshold;

COMMENT ON TABLE public.inventory_items IS 'General inventory and supplies';

-- =============================================
-- Tasks & Activities
-- =============================================

CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  assignee_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  due_date DATE,
  priority TEXT DEFAULT 'medium', -- low, medium, high, urgent
  status task_status DEFAULT 'pending',
  related_entity_type TEXT, -- animal, production, health, etc.
  related_entity_id UUID,
  notes TEXT,
  created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tasks_assignee ON public.tasks(assignee_id);
CREATE INDEX idx_tasks_status ON public.tasks(status);
CREATE INDEX idx_tasks_due_date ON public.tasks(due_date);

COMMENT ON TABLE public.tasks IS 'Task management and assignments';

CREATE TABLE public.activity_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  action TEXT NOT NULL, -- created, updated, deleted
  entity_type TEXT NOT NULL,
  entity_id UUID,
  metadata JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_activity_logs_user ON public.activity_logs(user_id);
CREATE INDEX idx_activity_logs_entity ON public.activity_logs(entity_type, entity_id);
CREATE INDEX idx_activity_logs_created ON public.activity_logs(created_at DESC);

COMMENT ON TABLE public.activity_logs IS 'Audit trail and activity history';

-- =============================================
-- Attachments
-- =============================================

CREATE TABLE public.attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  file_name TEXT NOT NULL,
  file_type TEXT,
  file_size INTEGER,
  storage_path TEXT NOT NULL,
  url TEXT NOT NULL,
  uploaded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_attachments_entity ON public.attachments(entity_type, entity_id);

COMMENT ON TABLE public.attachments IS 'File attachments for various entities';

-- =============================================
-- Triggers for updated_at
-- =============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_animals_updated_at BEFORE UPDATE ON public.animals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_milk_productions_updated_at BEFORE UPDATE ON public.milk_productions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feeds_updated_at BEFORE UPDATE ON public.feeds
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_health_records_updated_at BEFORE UPDATE ON public.health_records
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON public.suppliers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON public.customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON public.sales
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_items_updated_at BEFORE UPDATE ON public.inventory_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON public.tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
