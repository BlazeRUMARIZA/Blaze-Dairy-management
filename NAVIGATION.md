# 🚀 Quick Navigation Guide

## All Application Pages

### 📱 Authentication
- `/pages/auth/login.html` - Login page
- `/pages/auth/signup.html` - Register new user
- `/pages/auth/forgot-password.html` - Reset password

### 🏠 Main Dashboard
- `/index.html` - Dashboard with KPIs, charts, activity

### 🐄 Livestock Management
- `/pages/animals/list.html` - View all animals
- `/pages/animals/add.html` - Add new animal
- `/pages/animals/edit.html?id=XXX` - Edit animal

### 🥛 Milk Production
- `/pages/production/list.html` - View production records
- `/pages/production/add.html` - Record daily production
- `/pages/production/edit.html?id=XXX` - Edit production record

### 🌾 Feed Management
- `/pages/feed/list.html` - View feed catalog
- `/pages/feed/add.html` - Add new feed
- `/pages/feed/edit.html?id=XXX` - Edit feed

### ❤️ Health Records
- `/pages/health/list.html` - View health events
- `/pages/health/add.html` - Add health record
- `/pages/health/edit.html?id=XXX` - Edit health record

### 💰 Sales
- `/pages/sales/list.html` - View sales ledger
- `/pages/sales/add.html` - Record new sale
- `/pages/sales/edit.html?id=XXX` - Edit sale

### 💸 Expenses
- `/pages/expenses/list.html` - View expenses
- `/pages/expenses/add.html` - Add expense
- `/pages/expenses/edit.html?id=XXX` - Edit expense

### 📦 Inventory
- `/pages/inventory/list.html` - View inventory items
- `/pages/inventory/add.html` - Add inventory item
- `/pages/inventory/edit.html?id=XXX` - Edit item

### ✓ Tasks
- `/pages/tasks/list.html` - View all tasks
- `/pages/tasks/add.html` - Create new task
- `/pages/tasks/edit.html?id=XXX` - Edit task

### ⚙️ Settings
- `/pages/settings/profile.html` - User profile & password
- `/pages/settings/settings.html` - User management (Admin only)

---

## Module Icons Reference

Copy these SVG icons when creating new pages:

```html
<!-- Dashboard -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
</svg>

<!-- Livestock -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <circle cx="12" cy="12" r="3"/>
    <path d="M12 1v6m0 6v6m8.66-15.66l-4.24 4.24m-4.84 4.84l-4.24 4.24M23 12h-6m-6 0H1"/>
</svg>

<!-- Production -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M12 2v20M2 7h20M2 17h20"/>
</svg>

<!-- Feed -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <rect x="2" y="7" width="20" height="15" rx="2"/>
    <path d="M16 3h-8v4h8V3z"/>
</svg>

<!-- Health -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
</svg>

<!-- Sales -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <circle cx="9" cy="21" r="1"/>
    <circle cx="20" cy="21" r="1"/>
    <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
</svg>

<!-- Expenses -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <line x1="12" y1="1" x2="12" y2="23"/>
    <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
</svg>

<!-- Inventory -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
</svg>

<!-- Tasks -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M9 11l3 3L22 4"/>
    <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
</svg>

<!-- Plus (Add) -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M12 5v14m-7-7h14"/>
</svg>

<!-- Edit -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
</svg>

<!-- Delete -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
</svg>

<!-- Export -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4m4-5l5-5m0 0l5 5m-5-5v12"/>
</svg>
```

---

## Database Tables

- `users` - User accounts and roles
- `animals` - Livestock registry
- `milk_productions` - Daily production records
- `feeds` - Feed catalog
- `feed_logs` - Feed consumption records
- `health_records` - Health events and treatments
- `suppliers` - Supplier contacts
- `customers` - Customer contacts
- `sales` - Sales transactions
- `expenses` - Expense records
- `inventory_items` - Inventory catalog
- `tasks` - Task management
- `activity_logs` - System activity tracking
- `attachments` - File attachments

---

## Common Workflows

### Daily Production Recording
1. Go to Production → Add Production
2. Select today's date (auto-filled)
3. Choose shift (morning/evening/night)
4. Select animal from dropdown
5. Enter quantity in liters
6. Optionally add quality metrics (Fat%, SNF%)
7. Click Save

### Adding New Animal
1. Go to Livestock → Add Animal
2. Enter unique tag number (required)
3. Fill in breed, sex, birth date
4. Set status (usually "active")
5. Add parent tags if known (dam/sire)
6. Click Save

### Recording Health Event
1. Go to Health → Add Record
2. Select event date and animal
3. Choose event type (vaccination, treatment, etc.)
4. Enter description and cost
5. Set next due date if applicable
6. Click Save

### Creating Task
1. Go to Tasks → Add Task
2. Enter title and description
3. Set due date and priority
4. Assign to user
5. Set initial progress (usually 0%)
6. Click Save

---

## Admin Tasks

### Making a User Admin
1. Go to Settings → User Management (admin only)
2. Find the user in the table
3. Click "Edit Role" button
4. Select "Admin" from dropdown
5. Click Update

### Viewing System Analytics
1. Go to Dashboard
2. View KPI cards for quick stats
3. Check charts for trends
4. Review alerts for issues
5. See recent activity feed

---

## Tips

- 📊 **Export Data**: All list pages have Export button (CSV format)
- 🔍 **Search**: Use search boxes to quickly find records
- 🎯 **Filters**: Apply filters to narrow down results
- 📱 **Mobile**: App works on phones and tablets
- 🔐 **Security**: Logout when done on shared devices
- 💾 **Save Often**: Click Save after entering data
- ✅ **Validation**: Red text shows what needs fixing in forms

---

## Support

- **Setup Issues**: See [QUICKSTART.md](QUICKSTART.md)
- **Deployment**: See [DEPLOYMENT.md](DEPLOYMENT.md)
- **Features**: See [COMPLETION.md](COMPLETION.md)
- **Database**: See migration files in `database/migrations/`

---

**Quick Start**: `python3 -m http.server 8000` then visit http://localhost:8000
