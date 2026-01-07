hw// Authentication utilities
import supabase from './supabase-client.js';

// Check if user is authenticated
export async function checkAuth() {
  const { data: { session }, error } = await supabase.auth.getSession();
  
  if (error) {
    console.error('Auth check error:', error);
    return null;
  }
  
  return session;
}

// Get current user profile
export async function getCurrentUser() {
  const { data: { user }, error } = await supabase.auth.getUser();
  
  if (error || !user) {
    return null;
  }
  
  // Get extended profile from users table
  const { data: profile, error: profileError } = await supabase
    .from('users')
    .select('*')
    .eq('id', user.id)
    .single();
  
  if (profileError) {
    console.error('Profile fetch error:', profileError);
    return { ...user, role: 'staff' }; // Default role
  }
  
  return { ...user, ...profile };
}

// Sign in with email and password
export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });
  
  if (error) {
    throw new Error(error.message);
  }
  
  return data;
}

// Sign up new user
export async function signUp(email, password, fullName, role = 'staff') {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
        role: role
      }
    }
  });
  
  if (error) {
    throw new Error(error.message);
  }
  
  // Create user profile
  if (data.user) {
    const { error: profileError } = await supabase
      .from('users')
      .insert({
        id: data.user.id,
        email: email,
        full_name: fullName,
        role: role,
        status: 'active'
      });
    
    if (profileError) {
      console.error('Profile creation error:', profileError);
    }
  }
  
  return data;
}

// Sign out
export async function signOut() {
  const { error } = await supabase.auth.signOut();
  
  if (error) {
    throw new Error(error.message);
  }
  
  // Redirect to login
  window.location.href = '/pages/auth/login.html';
}

// Reset password
export async function resetPassword(email) {
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${window.location.origin}/pages/auth/reset-password.html`
  });
  
  if (error) {
    throw new Error(error.message);
  }
}

// Update password
export async function updatePassword(newPassword) {
  const { error } = await supabase.auth.updateUser({
    password: newPassword
  });
  
  if (error) {
    throw new Error(error.message);
  }
}

// Require authentication (use on protected pages)
export async function requireAuth() {
  const session = await checkAuth();
  
  if (!session) {
    // Store the intended destination
    sessionStorage.setItem('redirectAfterLogin', window.location.pathname);
    window.location.href = '/pages/auth/login.html';
    return null;
  }
  
  return session;
}

// Check if user has admin role
export async function isAdmin() {
  const user = await getCurrentUser();
  return user && user.role === 'admin';
}

// Require admin access
export async function requireAdmin() {
  const admin = await isAdmin();
  
  if (!admin) {
    window.location.href = '/index.html';
    return false;
  }
  
  return true;
}

// Listen for auth state changes
export function onAuthStateChange(callback) {
  return supabase.auth.onAuthStateChange((event, session) => {
    callback(event, session);
  });
}
