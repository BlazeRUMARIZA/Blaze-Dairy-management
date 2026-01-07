# Blaze Dairy Management - Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### 1. Supabase Setup

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Click "New Project"
   - Set project name: "blaze-dairy"
   - Choose a database password
   - Select a region close to you
   - Wait for project to be created (~2 minutes)

2. **Run Database Migrations**
   - Go to SQL Editor in Supabase dashboard
   - Run these files in order:
     1. `database/migrations/001_initial_schema.sql`
     2. `database/migrations/002_rls_policies.sql`
     3. `database/migrations/003_functions.sql`
   - (Optional) Run `database/sample_data.sql` for test data

3. **Create Storage Buckets**
   - Go to Storage in Supabase dashboard
   - Create bucket: `attachments` (private)
   - Create bucket: `animal_photos` (private)

4. **Get API Keys**
   - Go to Settings → API
   - Copy "Project URL" and "anon public" key

### 2. App Configuration

1. **Clone or Download the Repository**
   ```bash
   cd Blaze-Dairy-management
   ```

2. **Configure Supabase**
   - Copy `config.example.js` to `config.js`
   - Update with your Supabase credentials:
   ```javascript
   export const SUPABASE_URL = 'https://your-project-id.supabase.co';
   export const SUPABASE_ANON_KEY = 'your-anon-key';
   ```

### 3. Run the App

**Option A: Simple HTTP Server (Python)**
```bash
python -m http.server 8000
# Open http://localhost:8000
```

**Option B: Node.js Server**
```bash
npx serve
# Open http://localhost:3000
```

**Option C: Live Server (VS Code Extension)**
- Install "Live Server" extension
- Right-click `index.html` → "Open with Live Server"

### 4. Create First User

1. Open the app in browser
2. Click "Sign up"
3. Fill in details:
   - Full Name: Admin User
   - Email: admin@yourdomain.com
   - Password: (at least 6 characters)
4. Check your email for verification link
5. After verification, sign in

### 5. Set Admin Role (Important!)

Since the first user needs admin access:

1. Go to Supabase dashboard → Authentication → Users
2. Find your user
3. Go to SQL Editor and run:
```sql
UPDATE public.users 
SET role = 'admin' 
WHERE email = 'admin@yourdomain.com';
```

## 📱 First Steps After Login

1. **Dashboard**: Overview of your farm operations
2. **Register Animals**: Add your livestock (Animals → Add New)
3. **Record Production**: Log daily milk production
4. **Add Feeds**: Set up your feed inventory
5. **Track Expenses**: Start logging costs

## 🔑 Default Test Users (if you ran sample_data.sql)

```
Admin Account:
- Email: admin@blaze.com
- Role: Admin (full access)

Staff Account:
- Email: staff@blaze.com
- Role: Staff (limited access)
```

Note: You'll need to create these users in Supabase Auth first, then update their IDs in sample_data.sql

## 🎯 Key Features to Explore

### For Admins
- ✅ Full CRUD access to all modules
- ✅ User management
- ✅ Financial reports
- ✅ System settings

### For Staff
- ✅ Record daily production
- ✅ Log feed consumption
- ✅ Update animal health records
- ✅ View assigned tasks

## 📊 Understanding the Dashboard

- **KPI Cards**: Today's production, active animals, revenue, health events
- **Charts**: Production trends and financial overview
- **Alerts**: Low stock warnings, upcoming health events, overdue tasks
- **Quick Actions**: Fast access to common operations

## 🔧 Troubleshooting

### Issue: "Failed to initialize application"
- **Solution**: Check your `config.js` has correct Supabase credentials
- Verify Supabase project is active

### Issue: Can't see any data
- **Solution**: Make sure you've run all migrations
- Check RLS policies are enabled
- Verify you're signed in

### Issue: "Permission denied" errors
- **Solution**: Check your user role in `public.users` table
- Ensure RLS policies were created correctly

### Issue: Charts not showing
- **Solution**: Add some sample data first
- Check browser console for JavaScript errors

## 📚 Next Steps

1. **Customize**: Adjust colors, branding in CSS files
2. **Add Data**: Import your existing animal records
3. **Train Team**: Show staff how to use the system
4. **Mobile**: Test on mobile devices (responsive design)
5. **Backup**: Set up Supabase backup schedule

## 🚀 Deployment

### Deploy to Netlify (Free)

1. Push code to GitHub
2. Go to [netlify.com](https://netlify.com)
3. Click "New site from Git"
4. Connect GitHub repository
5. Set environment variables (if needed)
6. Deploy!

### Deploy to Vercel (Free)

```bash
npm install -g vercel
vercel
```

## 🔐 Security Best Practices

1. **Never commit config.js** (it's in .gitignore)
2. **Use environment variables** for production
3. **Enable 2FA** on Supabase account
4. **Regular backups** of your database
5. **Update passwords** periodically
6. **Monitor activity logs** for suspicious behavior

## 📞 Support

- **Documentation**: See README.md for full details
- **Issues**: Check browser console for errors
- **Database**: Use Supabase SQL Editor to debug queries

## ✅ Pre-Launch Checklist

- [ ] Database migrations run successfully
- [ ] Storage buckets created
- [ ] RLS policies enabled
- [ ] Admin user created and verified
- [ ] Sample data loaded (optional)
- [ ] App loads without errors
- [ ] Can create and view records
- [ ] Charts displaying data
- [ ] Mobile view works

## 🎉 You're Ready!

Your Blaze Dairy Management system is now set up and ready to use. Start by adding your animals and recording your first production entry!

---

**Need Help?** Check the full README.md for detailed documentation.
