// Authentication check for protected pages
import { checkAuth } from './auth.js';

// Check authentication immediately on page load
(async () => {
    const session = await checkAuth();
    if (!session) {
        // No session, redirect to login
        const loginPath = window.location.pathname.includes('/pages/') 
            ? '../auth/login.html' 
            : 'pages/auth/login.html';
        window.location.href = loginPath;
        return;
    }
    // User is authenticated, continue loading
})();
