// Supabase Client Initialization
import { SUPABASE_URL, SUPABASE_ANON_KEY } from '../config.js';

// Initialize Supabase client
export const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Export for use in other modules
export default supabase;
