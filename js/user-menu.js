// Standalone user menu dropdown script
// This runs immediately without waiting for modules or auth
(function() {
    'use strict';
    
    function setupUserMenuDropdown() {
        const userMenuBtn = document.getElementById('userMenuBtn');
        const userMenu = document.getElementById('userMenu');
        
        if (!userMenuBtn || !userMenu) {
            console.warn('User menu elements not found');
            return false;
        }
        
        // Hide menu items based on current page
        const currentPath = window.location.pathname;
        const profileLink = userMenu.querySelector('a[href*="profile.html"]');
        const settingsLink = userMenu.querySelector('a[href*="settings.html"]');
        
        // Hide Profile link when on profile page
        if (currentPath.includes('profile.html') && profileLink) {
            profileLink.style.display = 'none';
        }
        
        // Hide Settings link when on settings page
        if (currentPath.includes('settings.html') && settingsLink) {
            settingsLink.style.display = 'none';
        }
        
        // Toggle dropdown on button click
        userMenuBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const isActive = userMenu.classList.toggle('active');
            userMenuBtn.classList.toggle('active', isActive);
        });
        
        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            if (!userMenu.contains(e.target) && !userMenuBtn.contains(e.target)) {
                userMenu.classList.remove('active');
                userMenuBtn.classList.remove('active');
            }
        });
        
        // Prevent clicks inside menu from closing it
        userMenu.addEventListener('click', function(e) {
            e.stopPropagation();
        });
        
        return true;
    }
    
    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', setupUserMenuDropdown);
    } else {
        setupUserMenuDropdown();
    }
})();
