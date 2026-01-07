-- =============================================
-- Blaze Dairy Management - Additional Columns
-- Migration 004: Add quality_grade to milk_productions
--                Add status to feeds
-- =============================================

-- Add quality_grade to milk_productions
ALTER TABLE public.milk_productions 
ADD COLUMN IF NOT EXISTS quality_grade TEXT CHECK (quality_grade IN ('A', 'B', 'C', 'rejected'));

COMMENT ON COLUMN public.milk_productions.quality_grade IS 'Milk quality grade: A (premium), B (standard), C (below standard), rejected';

-- Add status to feeds
ALTER TABLE public.feeds 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'discontinued'));

COMMENT ON COLUMN public.feeds.status IS 'Feed status: active, inactive, discontinued';
