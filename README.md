# Blaze Dairy Management System

A modern web application for comprehensive dairy farm management including livestock tracking, milk production, feed management, health records, sales, expenses, and analytics.

## Features

- **Livestock Management**: Track animals, lifecycle events, breeding, and lineage
- **Milk Production**: Daily/shift entries with quality metrics and trends
- **Feed Management**: Stock tracking, ration planning, consumption logs
- **Health Records**: Treatments, vaccinations, vet visits with alerts
- **Sales & Expenses**: Customer orders, invoices, expense tracking
- **Inventory**: Supplies management with low-stock alerts
- **Dashboard & Analytics**: KPIs, charts, and actionable insights
- **Role-Based Access**: Admin and staff roles with granular permissions

## Tech Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Charts**: Chart.js
- **Hosting**: Netlify/Vercel + Supabase

## Setup Instructions

### 1. Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Run the SQL migrations from `/database/migrations/` in order
3. Set up storage buckets: `attachments`, `animal_photos`
4. Configure RLS policies (included in migrations)

### 2. Configuration

Create `config.js` with your Supabase credentials:

```javascript
export const SUPABASE_URL = 'your-project-url';
export const SUPABASE_ANON_KEY = 'your-anon-key';
```

### 3. Local Development

Simply open `index.html` in a browser or use a local server:

```bash
# Python
python -m http.server 8000

# Node
npx serve
```

### 4. Deployment

Deploy to Netlify or Vercel:
- Build command: (none needed - static site)
- Publish directory: `/`
- Environment variables: Set in hosting platform settings

## Project Structure

```
/
├── index.html              # Landing/Dashboard
├── config.js               # Supabase configuration
├── css/
│   ├── main.css           # Global styles
│   ├── components.css     # Reusable components
│   └── pages/             # Page-specific styles
├── js/
│   ├── app.js             # Main application logic
│   ├── supabase-client.js # Supabase initialization
│   ├── auth.js            # Authentication utilities
│   ├── utils.js           # Helper functions
│   └── modules/           # Feature modules
├── pages/
│   ├── auth/              # Login, signup, reset
│   ├── animals/           # Livestock management
│   ├── production/        # Milk production
│   ├── feed/              # Feed management
│   ├── health/            # Health records
│   ├── sales/             # Sales tracking
│   ├── expenses/          # Expense tracking
│   ├── inventory/         # Inventory management
│   ├── contacts/          # Suppliers & customers
│   ├── tasks/             # Task management
│   └── settings/          # User settings
├── database/
│   └── migrations/        # SQL schema files
└── assets/
    └── icons/             # SVG icons
```

## User Roles

- **Admin**: Full access to all modules, user management, analytics
- **Staff**: Limited access based on assignments, restricted analytics

## License

MIT License
