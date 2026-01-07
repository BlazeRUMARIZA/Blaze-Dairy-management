-- =============================================
-- Blaze Dairy Management - Helper Functions
-- Migration 003: RPC Functions for Analytics
-- =============================================

-- =============================================
-- Dashboard KPIs
-- =============================================

-- Get today's total production
CREATE OR REPLACE FUNCTION get_daily_production(target_date DATE DEFAULT CURRENT_DATE)
RETURNS TABLE (
  total_volume DECIMAL,
  animal_count INTEGER,
  avg_per_animal DECIMAL,
  morning_volume DECIMAL,
  evening_volume DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(SUM(volume_liters), 0) as total_volume,
    COUNT(DISTINCT animal_id)::INTEGER as animal_count,
    COALESCE(AVG(volume_liters), 0) as avg_per_animal,
    COALESCE(SUM(CASE WHEN shift = 'morning' THEN volume_liters ELSE 0 END), 0) as morning_volume,
    COALESCE(SUM(CASE WHEN shift = 'evening' THEN volume_liters ELSE 0 END), 0) as evening_volume
  FROM public.milk_productions
  WHERE production_date = target_date;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get production trend (last N days)
CREATE OR REPLACE FUNCTION get_production_trend(days INTEGER DEFAULT 7)
RETURNS TABLE (
  production_date DATE,
  total_volume DECIMAL,
  animal_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d::DATE as production_date,
    COALESCE(SUM(mp.volume_liters), 0) as total_volume,
    COUNT(DISTINCT mp.animal_id)::INTEGER as animal_count
  FROM generate_series(
    CURRENT_DATE - (days - 1), 
    CURRENT_DATE, 
    '1 day'::interval
  ) AS d
  LEFT JOIN public.milk_productions mp ON mp.production_date = d::DATE
  GROUP BY d
  ORDER BY d;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get animal statistics
CREATE OR REPLACE FUNCTION get_animal_stats()
RETURNS TABLE (
  total_animals INTEGER,
  active_animals INTEGER,
  producing_today INTEGER,
  new_this_month INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER as total_animals,
    COUNT(*) FILTER (WHERE status = 'active')::INTEGER as active_animals,
    (
      SELECT COUNT(DISTINCT animal_id)::INTEGER 
      FROM public.milk_productions 
      WHERE production_date = CURRENT_DATE
    ) as producing_today,
    COUNT(*) FILTER (
      WHERE created_at >= date_trunc('month', CURRENT_DATE)
    )::INTEGER as new_this_month
  FROM public.animals;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get financial summary (MTD)
CREATE OR REPLACE FUNCTION get_financial_summary(
  start_date DATE DEFAULT date_trunc('month', CURRENT_DATE)::DATE,
  end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  total_revenue DECIMAL,
  total_expenses DECIMAL,
  net_profit DECIMAL,
  sales_count INTEGER,
  expense_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE((SELECT SUM(total_amount) FROM public.sales WHERE sale_date BETWEEN start_date AND end_date), 0) as total_revenue,
    COALESCE((SELECT SUM(amount) FROM public.expenses WHERE expense_date BETWEEN start_date AND end_date), 0) as total_expenses,
    COALESCE((SELECT SUM(total_amount) FROM public.sales WHERE sale_date BETWEEN start_date AND end_date), 0) -
    COALESCE((SELECT SUM(amount) FROM public.expenses WHERE expense_date BETWEEN start_date AND end_date), 0) as net_profit,
    (SELECT COUNT(*)::INTEGER FROM public.sales WHERE sale_date BETWEEN start_date AND end_date) as sales_count,
    (SELECT COUNT(*)::INTEGER FROM public.expenses WHERE expense_date BETWEEN start_date AND end_date) as expense_count;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get revenue vs expense trend
CREATE OR REPLACE FUNCTION get_revenue_expense_trend(days INTEGER DEFAULT 30)
RETURNS TABLE (
  date DATE,
  revenue DECIMAL,
  expenses DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d::DATE as date,
    COALESCE((SELECT SUM(total_amount) FROM public.sales WHERE sale_date = d), 0) as revenue,
    COALESCE((SELECT SUM(amount) FROM public.expenses WHERE expense_date = d), 0) as expenses
  FROM generate_series(
    CURRENT_DATE - (days - 1), 
    CURRENT_DATE, 
    '1 day'::interval
  ) AS d
  ORDER BY d;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get health events summary
CREATE OR REPLACE FUNCTION get_health_summary(days INTEGER DEFAULT 7)
RETURNS TABLE (
  event_type health_event_type,
  event_count INTEGER,
  total_cost DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    hr.event_type,
    COUNT(*)::INTEGER as event_count,
    COALESCE(SUM(hr.cost), 0) as total_cost
  FROM public.health_records hr
  WHERE hr.event_date >= CURRENT_DATE - days
  GROUP BY hr.event_type
  ORDER BY event_count DESC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- =============================================
-- Animal-Specific Functions
-- =============================================

-- Get animal performance metrics
CREATE OR REPLACE FUNCTION get_animal_kpis(p_animal_id UUID, days INTEGER DEFAULT 30)
RETURNS TABLE (
  avg_daily_production DECIMAL,
  total_production DECIMAL,
  production_days INTEGER,
  avg_fat_percentage DECIMAL,
  last_health_event DATE,
  total_feed_cost DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(AVG(mp.volume_liters), 0) as avg_daily_production,
    COALESCE(SUM(mp.volume_liters), 0) as total_production,
    COUNT(DISTINCT mp.production_date)::INTEGER as production_days,
    COALESCE(AVG(mp.fat_percentage), 0) as avg_fat_percentage,
    (SELECT MAX(event_date) FROM public.health_records WHERE animal_id = p_animal_id) as last_health_event,
    COALESCE((SELECT SUM(cost) FROM public.feed_logs WHERE animal_id = p_animal_id AND feeding_date >= CURRENT_DATE - days), 0) as total_feed_cost
  FROM public.milk_productions mp
  WHERE mp.animal_id = p_animal_id 
    AND mp.production_date >= CURRENT_DATE - days;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- =============================================
-- Alerts & Notifications
-- =============================================

-- Get low stock items
CREATE OR REPLACE FUNCTION get_low_stock_items()
RETURNS TABLE (
  id UUID,
  name TEXT,
  current_stock DECIMAL,
  min_threshold DECIMAL,
  deficit DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ii.id,
    ii.name,
    ii.quantity as current_stock,
    ii.min_threshold,
    (ii.min_threshold - ii.quantity) as deficit
  FROM public.inventory_items ii
  WHERE ii.quantity <= ii.min_threshold
  ORDER BY deficit DESC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get low feed stock
CREATE OR REPLACE FUNCTION get_low_feed_stock()
RETURNS TABLE (
  id UUID,
  name TEXT,
  category TEXT,
  current_stock DECIMAL,
  min_threshold DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.name,
    f.category,
    f.current_stock,
    f.min_stock_threshold
  FROM public.feeds f
  WHERE f.current_stock <= f.min_stock_threshold
  ORDER BY (f.min_stock_threshold - f.current_stock) DESC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get upcoming health events
CREATE OR REPLACE FUNCTION get_upcoming_health_events(days_ahead INTEGER DEFAULT 7)
RETURNS TABLE (
  animal_id UUID,
  animal_tag TEXT,
  animal_name TEXT,
  next_visit_date DATE,
  last_event_type health_event_type,
  days_until INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id as animal_id,
    a.tag_id as animal_tag,
    a.name as animal_name,
    hr.next_visit_date,
    hr.event_type as last_event_type,
    (hr.next_visit_date - CURRENT_DATE)::INTEGER as days_until
  FROM public.health_records hr
  JOIN public.animals a ON a.id = hr.animal_id
  WHERE hr.next_visit_date IS NOT NULL
    AND hr.next_visit_date BETWEEN CURRENT_DATE AND CURRENT_DATE + days_ahead
  ORDER BY hr.next_visit_date;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get overdue tasks
CREATE OR REPLACE FUNCTION get_overdue_tasks()
RETURNS TABLE (
  id UUID,
  title TEXT,
  due_date DATE,
  assignee_name TEXT,
  days_overdue INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.title,
    t.due_date,
    u.full_name as assignee_name,
    (CURRENT_DATE - t.due_date)::INTEGER as days_overdue
  FROM public.tasks t
  LEFT JOIN public.users u ON u.id = t.assignee_id
  WHERE t.status != 'completed' 
    AND t.status != 'cancelled'
    AND t.due_date < CURRENT_DATE
  ORDER BY days_overdue DESC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- =============================================
-- Reporting Functions
-- =============================================

-- Get top producing animals
CREATE OR REPLACE FUNCTION get_top_producers(days INTEGER DEFAULT 30, limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
  animal_id UUID,
  tag_id TEXT,
  name TEXT,
  total_production DECIMAL,
  avg_daily DECIMAL,
  production_days INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id as animal_id,
    a.tag_id,
    a.name,
    COALESCE(SUM(mp.volume_liters), 0) as total_production,
    COALESCE(AVG(mp.volume_liters), 0) as avg_daily,
    COUNT(DISTINCT mp.production_date)::INTEGER as production_days
  FROM public.animals a
  LEFT JOIN public.milk_productions mp ON mp.animal_id = a.id 
    AND mp.production_date >= CURRENT_DATE - days
  WHERE a.status = 'active'
  GROUP BY a.id, a.tag_id, a.name
  ORDER BY total_production DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get expense breakdown by category
CREATE OR REPLACE FUNCTION get_expense_breakdown(
  start_date DATE DEFAULT date_trunc('month', CURRENT_DATE)::DATE,
  end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  category expense_category,
  total_amount DECIMAL,
  transaction_count INTEGER,
  avg_amount DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.category,
    COALESCE(SUM(e.amount), 0) as total_amount,
    COUNT(*)::INTEGER as transaction_count,
    COALESCE(AVG(e.amount), 0) as avg_amount
  FROM public.expenses e
  WHERE e.expense_date BETWEEN start_date AND end_date
  GROUP BY e.category
  ORDER BY total_amount DESC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Get recent activity
CREATE OR REPLACE FUNCTION get_recent_activity(limit_count INTEGER DEFAULT 20)
RETURNS TABLE (
  id UUID,
  action TEXT,
  entity_type TEXT,
  entity_id UUID,
  user_name TEXT,
  created_at TIMESTAMPTZ,
  metadata JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    al.id,
    al.action,
    al.entity_type,
    al.entity_id,
    u.full_name as user_name,
    al.created_at,
    al.metadata
  FROM public.activity_logs al
  LEFT JOIN public.users u ON u.id = al.user_id
  ORDER BY al.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- =============================================
-- Grant permissions
-- =============================================

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;
