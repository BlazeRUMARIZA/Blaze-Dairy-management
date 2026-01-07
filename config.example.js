// Copy this file to config.js and fill in your Supabase credentials
export const SUPABASE_URL = 'https://your-project-id.supabase.co';
export const SUPABASE_ANON_KEY = 'your-anon-key-here';

// App configuration
export const APP_CONFIG = {
  appName: 'Blaze Dairy Management',
  appVersion: '1.0.0',
  defaultDateFormat: 'YYYY-MM-DD',
  itemsPerPage: 20,
  chartColors: {
    primary: '#3b82f6',
    secondary: '#8b5cf6',
    success: '#10b981',
    warning: '#f59e0b',
    danger: '#ef4444',
    info: '#06b6d4'
  },
  roles: {
    ADMIN: 'admin',
    STAFF: 'staff'
  }
};
