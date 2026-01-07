// Main application initialization
import { requireAuth, getCurrentUser, signOut } from './auth.js';
import { showToast } from './utils.js';

// Initialize app
async function initApp() {
  try {
    // Check authentication
    const session = await requireAuth();
    if (!session) return;
    
    // Get current user
    const user = await getCurrentUser();
    if (user) {
      updateUserUI(user);
    }
    
    // Setup navigation
    setupNavigation();
    
    // Setup user menu
    setupUserMenu();
    
  } catch (error) {
    console.error('App initialization error:', error);
    showToast('Failed to initialize application', 'danger');
  }
}

// Update user UI
function updateUserUI(user) {
  const userName = document.getElementById('userName');
  const userAvatar = document.getElementById('userAvatar');
  
  if (userName && user.full_name) {
    userName.textContent = user.full_name;
  }
  
  if (userAvatar && user.full_name) {
    userAvatar.textContent = user.full_name.charAt(0).toUpperCase();
  }
  
  // Hide admin-only elements if not admin
  if (user.role !== 'admin') {
    document.querySelectorAll('[data-admin-only]').forEach(el => {
      el.style.display = 'none';
    });
  }
}

// Setup navigation
function setupNavigation() {
  // Mobile menu toggle
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const navMenu = document.getElementById('navMenu');
  
  if (mobileMenuBtn && navMenu) {
    mobileMenuBtn.addEventListener('click', () => {
      navMenu.classList.toggle('active');
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
      if (!e.target.closest('.nav-container')) {
        navMenu.classList.remove('active');
      }
    });
  }
  
  // Set active nav link
  const currentPath = window.location.pathname;
  document.querySelectorAll('.nav-link').forEach(link => {
    if (link.getAttribute('href') === currentPath || 
        (currentPath.includes(link.getAttribute('href')) && link.getAttribute('href') !== '/')) {
      link.classList.add('active');
    } else {
      link.classList.remove('active');
    }
  });
}

// Setup user menu
function setupUserMenu() {
  const userMenuBtn = document.getElementById('userMenuBtn');
  // User menu dropdown is handled by user-menu.js (loaded before app.js)
  // Only handle logout button here
  const logoutBtn = document.getElementById('logoutBtn');
  
  if (logoutBtn) {
    logoutBtn.addEventListener('click', async () => {
      try {
        await signOut();
      } catch (error) {
        console.error('Logout error:', error);
        showToast('Failed to logout', 'danger');
      }
    });
  }
}

// Form validation helper
export function validateForm(formId) {
  const form = document.getElementById(formId);
  if (!form) return false;
  
  let isValid = true;
  const inputs = form.querySelectorAll('input[required], select[required], textarea[required]');
  
  inputs.forEach(input => {
    const errorEl = input.parentElement.querySelector('.form-error');
    
    if (!input.value.trim()) {
      isValid = false;
      input.classList.add('error');
      if (errorEl) {
        errorEl.textContent = 'This field is required';
        errorEl.style.display = 'block';
      }
    } else {
      input.classList.remove('error');
      if (errorEl) {
        errorEl.style.display = 'none';
      }
    }
  });
  
  return isValid;
}

// Clear form
export function clearForm(formId) {
  const form = document.getElementById(formId);
  if (form) {
    form.reset();
    form.querySelectorAll('.form-error').forEach(el => {
      el.style.display = 'none';
    });
    form.querySelectorAll('.error').forEach(el => {
      el.classList.remove('error');
    });
  }
}

// Modal helpers
export function openModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
  }
}

export function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.style.display = 'none';
    document.body.style.overflow = 'auto';
  }
}

// Setup modal close handlers
export function setupModalCloseHandlers(modalId) {
  const modal = document.getElementById(modalId);
  if (!modal) return;
  
  // Close on overlay click
  modal.addEventListener('click', (e) => {
    if (e.target === modal) {
      closeModal(modalId);
    }
  });
  
  // Close on close button
  const closeBtn = modal.querySelector('.modal-close');
  if (closeBtn) {
    closeBtn.addEventListener('click', () => closeModal(modalId));
  }
  
  // Close on ESC key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && modal.style.display === 'flex') {
      closeModal(modalId);
    }
  });
}

// Pagination helper
export class Pagination {
  constructor(container, options = {}) {
    this.container = container;
    this.page = options.page || 1;
    this.limit = options.limit || 20;
    this.total = options.total || 0;
    this.onPageChange = options.onPageChange || (() => {});
  }
  
  get totalPages() {
    return Math.ceil(this.total / this.limit);
  }
  
  render() {
    if (!this.container || this.totalPages <= 1) return;
    
    this.container.innerHTML = `
      <div class="pagination">
        <button class="pagination-btn" ${this.page === 1 ? 'disabled' : ''} data-action="first">
          &laquo;
        </button>
        <button class="pagination-btn" ${this.page === 1 ? 'disabled' : ''} data-action="prev">
          &lsaquo;
        </button>
        <span style="padding: 0 1rem;">Page ${this.page} of ${this.totalPages}</span>
        <button class="pagination-btn" ${this.page === this.totalPages ? 'disabled' : ''} data-action="next">
          &rsaquo;
        </button>
        <button class="pagination-btn" ${this.page === this.totalPages ? 'disabled' : ''} data-action="last">
          &raquo;
        </button>
      </div>
    `;
    
    // Add event listeners
    this.container.querySelectorAll('[data-action]').forEach(btn => {
      btn.addEventListener('click', () => {
        const action = btn.dataset.action;
        switch(action) {
          case 'first': this.goToPage(1); break;
          case 'prev': this.goToPage(this.page - 1); break;
          case 'next': this.goToPage(this.page + 1); break;
          case 'last': this.goToPage(this.totalPages); break;
        }
      });
    });
  }
  
  goToPage(page) {
    if (page < 1 || page > this.totalPages) return;
    this.page = page;
    this.render();
    this.onPageChange(this.page);
  }
  
  setTotal(total) {
    this.total = total;
    this.render();
  }
}

// Initialize on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initApp);
} else {
  initApp();
}

// Export for use in modules
export { initApp };
