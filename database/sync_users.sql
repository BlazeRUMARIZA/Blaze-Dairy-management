-- Sync existing auth.users to public.users
-- Run this after creating users in Supabase Auth

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

-- Verify the sync
SELECT 
  u.id,
  u.email,
  u.role,
  u.full_name,
  u.status
FROM public.users u
ORDER BY u.created_at DESC;
