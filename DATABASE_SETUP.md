# Database Setup Guide

## Quick Setup for Supabase

Your Supabase project: `https://plmtwdcslzbwahidwfyp.supabase.co`

### Step 1: Run Database Migrations

Go to your Supabase Dashboard → **SQL Editor** and execute these files in order:

#### 1. Initial Schema (Required)
Copy and paste the entire content of `database/migrations/001_initial_schema.sql` into the SQL Editor and click **Run**.

This creates:
- All database tables (users, animals, milk_productions, feeds, health_records, sales, expenses, etc.)
- Custom types/enums (user_role, animal_status, shift_type, etc.)
- Indexes for performance
- Foreign key relationships

#### 2. Row Level Security Policies (Required)
Copy and paste the entire content of `database/migrations/002_rls_policies.sql` into the SQL Editor and click **Run**.

This sets up:
- Security policies to protect your data
- Role-based access control (admin vs staff)
- User isolation (users can only see their own profile)

#### 3. Database Functions (Required)
Copy and paste the entire content of `database/migrations/003_functions.sql` into the SQL Editor and click **Run**.

This creates:
- Helper functions for common operations
- Triggers for automatic timestamps
- Statistics calculation functions

### Step 2: Create First Admin User

1. Go to **Authentication** → **Users** → **Add user**
2. Create an admin account:
   - Email: `admin@blaze.com` (or your preferred email)
   - Password: Set a secure password
   - Confirm email automatically: ✓

3. After creating the user, go to **SQL Editor** and run:

```sql
-- Get the user ID from auth.users
SELECT id, email FROM auth.users WHERE email = 'admin@blaze.com';

-- Insert into public.users table (replace the UUID with the actual ID from above)
INSERT INTO public.users (id, email, role, full_name, status)
VALUES 
  ('PASTE-USER-ID-HERE', 'admin@blaze.com', 'admin', 'Admin User', 'active');
```

### Step 3: Optional - Load Sample Data

If you want to test with sample data, copy and paste `database/sample_data.sql` into the SQL Editor and click **Run**.

This will create:
- Sample animals (cows and bulls)
- Sample milk production records
- Sample feeds and feed logs
- Sample customers and suppliers
- Sample sales and expenses
- Sample health records
- Sample tasks and inventory items

### Step 4: Verify Setup

Run this query to verify everything is set up correctly:

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check if admin user exists
SELECT * FROM public.users WHERE role = 'admin';
```

You should see all the tables listed and your admin user.

### Step 5: Configure API Keys (Already Done! ✓)

Your config.js is already configured with:
- **Supabase URL**: `https://plmtwdcslzbwahidwfyp.supabase.co`
- **API Key**: `sb_publishable_suvXSo7eO-sH93rOV0y_Fw_rbtaKDax`

⚠️ **Important Note**: If authentication doesn't work, please verify you're using the correct **anon public** key from:
**Supabase Dashboard** → **Settings** → **API** → **Project API keys** → **anon** **public**

The key format should look like: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (very long JWT token)

### Step 6: Test the Application

1. Start your local server:
   ```bash
   python3 -m http.server 8000
   ```

2. Open your browser to: `http://localhost:8000`

3. Try logging in with the admin credentials you created

## Database Tables Overview

### Core Tables
- **users** - User profiles and roles
- **animals** - Livestock registry
- **milk_productions** - Daily milk records per animal
- **feeds** - Feed inventory
- **feed_logs** - Feed consumption records
- **health_records** - Animal health events
- **sales** - Sales transactions
- **expenses** - Business expenses
- **customers** - Customer database
- **suppliers** - Supplier database
- **inventory** - General inventory items
- **tasks** - Task management

### Security Features
- Row Level Security (RLS) enabled on all tables
- Role-based access control (admin/staff)
- Automatic timestamp updates
- Data validation via check constraints

## Troubleshooting

### Can't login?
1. Verify user exists in **Authentication** → **Users**
2. Check if user profile exists in `public.users` table
3. Verify the API key is correct (should be a long JWT token)

### Tables not showing up?
1. Make sure you ran all migration files in order
2. Check for errors in SQL Editor after running each migration

### Need to reset database?
Go to **Database** → **Tables** and delete all tables, then re-run migrations.

## Next Steps

1. Run the three migration files
2. Create your admin user
3. Optionally load sample data
4. Start using the application!

For more information, check the [QUICKSTART.md](QUICKSTART.md) guide.
