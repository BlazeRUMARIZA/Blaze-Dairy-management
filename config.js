// Blaze Dairy Management - Configuration
// Copy this file to config.js and fill in your Supabase credentials

export const SUPABASE_URL = 'https://plmtwdcslzbwahidwfyp.supabase.co';
export const SUPABASE_ANON_KEY = 'sb_publishable_suvXSo7eO-sH93rOV0y_Fw_rbtaKDax';

// Application configuration
export const APP_CONFIG = {
  appName: 'Blaze Dairy Management',
  appVersion: '1.0.0',
  
  // Date and time formats
  defaultDateFormat: 'YYYY-MM-DD',
  defaultTimeFormat: 'HH:mm',
  
  // Pagination
  itemsPerPage: 20,
  maxItemsPerPage: 100,
  
  // Charts
  chartColors: {
    primary: '#3b82f6',
    secondary: '#8b5cf6',
    success: '#10b981',
    warning: '#f59e0b',
    danger: '#ef4444',
    info: '#06b6d4'
  },
  
  // User roles
  roles: {
    ADMIN: 'admin',
    STAFF: 'staff'
  },
  
  // Status options
  animalStatus: {
    ACTIVE: 'active',
    SOLD: 'sold',
    DECEASED: 'deceased',
    TRANSFERRED: 'transferred'
  },
  
  // Feature flags
  features: {
    enableNotifications: true,
    enableExports: true,
    enableFileUploads: true,
    enableAdvancedAnalytics: true
  },
  
  // Limits and thresholds
  limits: {
    maxFileSize: 5 * 1024 * 1024, // 5MB
    maxFilesPerUpload: 5,
    lowStockThreshold: 10,
    criticalStockThreshold: 5
  }
};

// Export for use throughout the app
export default {
  SUPABASE_URL,
  SUPABASE_ANON_KEY,
  ...APP_CONFIG
};
