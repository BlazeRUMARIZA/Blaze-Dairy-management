// Dashboard module
import supabase from '../supabase-client.js';
import { formatDate, formatCurrency, formatNumber, showToast, handleError } from '../utils.js';

// Initialize dashboard
async function initDashboard() {
  try {
    await Promise.all([
      loadKPIs(),
      loadProductionChart(),
      loadFinanceChart(),
      loadRecentActivity(),
      loadAlerts()
    ]);
    
    setupEventListeners();
  } catch (error) {
    handleError(error, 'Failed to load dashboard');
  }
}

// Load KPIs
async function loadKPIs() {
  try {
    // Today's production
    const { data: productionData, error: prodError } = await supabase
      .rpc('get_daily_production', { target_date: formatDate(new Date()) });
    
    if (!prodError && productionData && productionData.length > 0) {
      const prod = productionData[0];
      document.getElementById('todayProduction').textContent = `${formatNumber(prod.total_volume, 1)} L`;
      
      // Get yesterday's production for comparison
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const { data: yesterdayData } = await supabase
        .rpc('get_daily_production', { target_date: formatDate(yesterday) });
      
      if (yesterdayData && yesterdayData.length > 0) {
        const change = ((prod.total_volume - yesterdayData[0].total_volume) / yesterdayData[0].total_volume * 100);
        const changeEl = document.getElementById('productionChange');
        changeEl.textContent = `${change > 0 ? '+' : ''}${formatNumber(change, 1)}%`;
        changeEl.className = `kpi-change ${change >= 0 ? 'positive' : 'negative'}`;
      }
    }
    
    // Animal stats
    const { data: animalStats, error: animalError } = await supabase
      .rpc('get_animal_stats');
    
    if (!animalError && animalStats && animalStats.length > 0) {
      const stats = animalStats[0];
      document.getElementById('activeAnimals').textContent = stats.active_animals || 0;
      document.getElementById('animalsChange').textContent = `${stats.producing_today || 0} producing`;
    }
    
    // Financial summary
    const { data: financeData, error: financeError } = await supabase
      .rpc('get_financial_summary');
    
    if (!financeError && financeData && financeData.length > 0) {
      const finance = financeData[0];
      document.getElementById('mtdRevenue').textContent = formatCurrency(finance.total_revenue);
      
      // Calculate change from last month
      const lastMonth = new Date();
      lastMonth.setMonth(lastMonth.getMonth() - 1);
      const startOfLastMonth = new Date(lastMonth.getFullYear(), lastMonth.getMonth(), 1);
      const endOfLastMonth = new Date(lastMonth.getFullYear(), lastMonth.getMonth() + 1, 0);
      
      const { data: lastMonthData } = await supabase
        .rpc('get_financial_summary', { 
          start_date: formatDate(startOfLastMonth),
          end_date: formatDate(endOfLastMonth)
        });
      
      if (lastMonthData && lastMonthData.length > 0 && lastMonthData[0].total_revenue > 0) {
        const change = ((finance.total_revenue - lastMonthData[0].total_revenue) / lastMonthData[0].total_revenue * 100);
        const changeEl = document.getElementById('revenueChange');
        changeEl.textContent = `${change > 0 ? '+' : ''}${formatNumber(change, 1)}%`;
        changeEl.className = `kpi-change ${change >= 0 ? 'positive' : 'negative'}`;
      }
    }
    
    // Health events
    const { data: healthData, error: healthError } = await supabase
      .rpc('get_health_summary', { days: 7 });
    
    if (!healthError && healthData) {
      const totalEvents = healthData.reduce((sum, item) => sum + item.event_count, 0);
      document.getElementById('healthEvents').textContent = totalEvents;
    }
    
  } catch (error) {
    console.error('KPI load error:', error);
  }
}

// Load production chart
async function loadProductionChart() {
  try {
    const days = parseInt(document.getElementById('productionPeriod')?.value || 7);
    
    const { data, error } = await supabase
      .rpc('get_production_trend', { days });
    
    if (error) throw error;
    
    const ctx = document.getElementById('productionChart');
    if (!ctx) return;
    
    // Destroy existing chart if any
    if (window.productionChart) {
      window.productionChart.destroy();
    }
    
    window.productionChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: data.map(d => formatDate(d.production_date)),
        datasets: [{
          label: 'Milk Production (L)',
          data: data.map(d => d.total_volume),
          borderColor: '#3b82f6',
          backgroundColor: 'rgba(59, 130, 246, 0.1)',
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: (context) => `${formatNumber(context.parsed.y, 1)} L`
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: (value) => `${value} L`
            }
          }
        }
      }
    });
  } catch (error) {
    console.error('Production chart error:', error);
  }
}

// Load finance chart
async function loadFinanceChart() {
  try {
    const days = parseInt(document.getElementById('financePeriod')?.value || 7);
    
    const { data, error } = await supabase
      .rpc('get_revenue_expense_trend', { days });
    
    if (error) throw error;
    
    const ctx = document.getElementById('financeChart');
    if (!ctx) return;
    
    // Destroy existing chart if any
    if (window.financeChart) {
      window.financeChart.destroy();
    }
    
    window.financeChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: data.map(d => formatDate(d.date)),
        datasets: [
          {
            label: 'Revenue',
            data: data.map(d => d.revenue),
            backgroundColor: '#10b981'
          },
          {
            label: 'Expenses',
            data: data.map(d => d.expenses),
            backgroundColor: '#ef4444'
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          tooltip: {
            callbacks: {
              label: (context) => `${context.dataset.label}: ${formatCurrency(context.parsed.y)}`
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: (value) => formatCurrency(value)
            }
          }
        }
      }
    });
  } catch (error) {
    console.error('Finance chart error:', error);
  }
}

// Load recent activity
async function loadRecentActivity() {
  try {
    const { data, error } = await supabase
      .rpc('get_recent_activity', { limit_count: 10 });
    
    if (error) throw error;
    
    const container = document.getElementById('activityList');
    if (!container) return;
    
    if (!data || data.length === 0) {
      container.innerHTML = `
        <div class="empty-state">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>
          </svg>
          <p>No recent activity</p>
        </div>
      `;
      return;
    }
    
    container.innerHTML = data.map(activity => `
      <div class="activity-item">
        <div class="activity-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
        </div>
        <div class="activity-content">
          <p class="activity-title">
            <strong>${activity.user_name || 'User'}</strong> ${activity.action} ${activity.entity_type}
          </p>
          <p class="activity-meta">${new Date(activity.created_at).toLocaleString()}</p>
        </div>
      </div>
    `).join('');
    
  } catch (error) {
    console.error('Activity load error:', error);
  }
}

// Load alerts
async function loadAlerts() {
  try {
    const alerts = [];
    
    // Low stock alerts
    const { data: lowStock, error: stockError } = await supabase
      .rpc('get_low_stock_items');
    
    if (!stockError && lowStock && lowStock.length > 0) {
      alerts.push({
        type: 'warning',
        message: `${lowStock.length} inventory item(s) are low on stock`
      });
    }
    
    // Upcoming health events
    const { data: healthEvents, error: healthError } = await supabase
      .rpc('get_upcoming_health_events', { days_ahead: 7 });
    
    if (!healthError && healthEvents && healthEvents.length > 0) {
      alerts.push({
        type: 'info',
        message: `${healthEvents.length} health event(s) scheduled in the next 7 days`
      });
    }
    
    // Overdue tasks
    const { data: overdueTasks, error: taskError } = await supabase
      .rpc('get_overdue_tasks');
    
    if (!taskError && overdueTasks && overdueTasks.length > 0) {
      alerts.push({
        type: 'danger',
        message: `${overdueTasks.length} task(s) are overdue`
      });
    }
    
    // Display alerts
    const container = document.getElementById('alertsContainer');
    if (container && alerts.length > 0) {
      alerts.forEach(alert => {
        const alertEl = document.createElement('div');
        alertEl.className = `alert alert-${alert.type}`;
        alertEl.innerHTML = `
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
          </svg>
          <div style="flex: 1;">${alert.message}</div>
          <button class="alert-close">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" style="width: 1.25rem; height: 1.25rem;">
              <path d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        `;
        
        // Add click handler for close button
        const closeBtn = alertEl.querySelector('.alert-close');
        closeBtn.addEventListener('click', () => alertEl.remove());
        
        container.appendChild(alertEl);
      });
    }
    
  } catch (error) {
    console.error('Alerts load error:', error);
  }
}

// Setup event listeners
function setupEventListeners() {
  // Refresh button
  const refreshBtn = document.getElementById('refreshBtn');
  if (refreshBtn) {
    refreshBtn.addEventListener('click', () => {
      showToast('Refreshing dashboard...', 'info');
      initDashboard();
    });
  }
  
  // Chart period selectors
  const productionPeriod = document.getElementById('productionPeriod');
  if (productionPeriod) {
    productionPeriod.addEventListener('change', loadProductionChart);
  }
  
  const financePeriod = document.getElementById('financePeriod');
  if (financePeriod) {
    financePeriod.addEventListener('change', loadFinanceChart);
  }
}

// Initialize on load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initDashboard);
} else {
  initDashboard();
}

export { initDashboard };
