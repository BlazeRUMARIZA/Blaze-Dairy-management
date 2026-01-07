# Deployment Guide - Blaze Dairy Management

This guide will help you deploy your Blaze Dairy Management application to production.

## 🚀 Deployment Options

### Option 1: Netlify (Recommended - Free Tier Available)

#### Step 1: Prepare Your Repository

```bash
# Initialize git if not already done
git init
git add .
git commit -m "Initial commit"

# Create GitHub repository and push
git remote add origin https://github.com/yourusername/blaze-dairy.git
git push -u origin main
```

#### Step 2: Deploy to Netlify

1. **Via Netlify Dashboard**
   - Go to [app.netlify.com](https://app.netlify.com)
   - Click "New site from Git"
   - Choose GitHub and select your repository
   - Configure build settings:
     - Build command: (leave empty)
     - Publish directory: `/`
   - Click "Deploy site"

2. **Via Netlify CLI**
   ```bash
   npm install -g netlify-cli
   netlify login
   netlify init
   netlify deploy --prod
   ```

#### Step 3: Configure Environment (if needed)

If you want to use environment variables instead of config.js:

1. Go to Site settings → Environment variables
2. Add:
   - `VITE_SUPABASE_URL`: Your Supabase URL
   - `VITE_SUPABASE_ANON_KEY`: Your Supabase anon key

Then update your config.js to use these:
```javascript
export const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'fallback-url';
export const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || 'fallback-key';
```

---

### Option 2: Vercel (Free Tier Available)

#### Deploy via Vercel CLI

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Deploy to production
vercel --prod
```

#### Deploy via Vercel Dashboard

1. Go to [vercel.com](https://vercel.com)
2. Click "New Project"
3. Import from Git repository
4. Configure:
   - Framework Preset: Other
   - Build Command: (leave empty)
   - Output Directory: `/`
5. Add environment variables if needed
6. Click "Deploy"

---

### Option 3: GitHub Pages (Free)

GitHub Pages is great for static sites:

#### Setup

1. Create a new repository on GitHub
2. Push your code
3. Go to repository Settings → Pages
4. Source: Deploy from a branch
5. Branch: main / root
6. Save

Your site will be available at: `https://yourusername.github.io/blaze-dairy/`

**Note**: Update all your links to include the base path if using a project page.

---

### Option 4: Self-Hosted (VPS/Server)

#### Requirements
- Linux server (Ubuntu 20.04+ recommended)
- Nginx or Apache
- SSL certificate (Let's Encrypt)

#### Setup with Nginx

```bash
# Upload files to server
scp -r * user@yourserver:/var/www/blaze-dairy/

# SSH into server
ssh user@yourserver

# Install Nginx
sudo apt update
sudo apt install nginx

# Configure Nginx
sudo nano /etc/nginx/sites-available/blaze-dairy

# Add this configuration:
server {
    listen 80;
    server_name yourdomain.com;
    root /var/www/blaze-dairy;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}

# Enable site
sudo ln -s /etc/nginx/sites-available/blaze-dairy /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Install SSL with Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

---

## 🔒 Production Security Checklist

### Before Going Live

- [ ] **Database Security**
  - [ ] RLS policies enabled on all tables
  - [ ] Service role key not exposed in frontend
  - [ ] Database backups configured in Supabase

- [ ] **Authentication**
  - [ ] Email confirmation enabled
  - [ ] Password requirements set (min 6 chars)
  - [ ] Rate limiting configured for auth endpoints

- [ ] **Environment Variables**
  - [ ] No credentials in config.js (use environment variables)
  - [ ] .gitignore includes config.js
  - [ ] Secrets stored securely in hosting platform

- [ ] **Content Security**
  - [ ] HTTPS enabled (SSL certificate)
  - [ ] CORS configured properly in Supabase
  - [ ] Storage buckets have proper access policies

- [ ] **Code Quality**
  - [ ] All console.logs removed or conditional
  - [ ] Error handling in place
  - [ ] Loading states implemented

---

## 🌐 Custom Domain Setup

### For Netlify

1. Go to Domain settings in Netlify dashboard
2. Click "Add custom domain"
3. Enter your domain (e.g., dairy.yourdomain.com)
4. Add DNS records as instructed:
   ```
   Type: A
   Name: @ (or subdomain)
   Value: [Netlify's IP]
   
   Type: CNAME
   Name: www
   Value: [your-site].netlify.app
   ```

### For Vercel

1. Go to Project settings → Domains
2. Add your domain
3. Configure DNS:
   ```
   Type: A
   Name: @
   Value: 76.76.21.21
   
   Type: CNAME
   Name: www
   Value: cname.vercel-dns.com
   ```

---

## 📊 Performance Optimization

### Pre-Deployment Optimizations

1. **Minify Assets**
   ```bash
   # Install build tools
   npm install -g html-minifier clean-css-cli uglify-js
   
   # Minify HTML
   html-minifier --collapse-whitespace --remove-comments index.html -o index.min.html
   
   # Minify CSS
   cleancss -o css/main.min.css css/main.css
   
   # Minify JS
   uglifyjs js/app.js -o js/app.min.js
   ```

2. **Image Optimization**
   - Use WebP format where possible
   - Compress images before uploading
   - Use appropriate dimensions

3. **Enable Caching**
   Add to your nginx config:
   ```nginx
   location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

### CDN Configuration

Use a CDN for better global performance:

1. **Cloudflare** (Free)
   - Add your site to Cloudflare
   - Update nameservers
   - Enable Auto Minify
   - Enable Rocket Loader

2. **Netlify/Vercel**
   - CDN included automatically
   - Global edge network
   - Automatic SSL

---

## 📈 Monitoring & Analytics

### Error Tracking

**Option 1: Sentry** (Free tier available)
```javascript
// Add to your HTML before other scripts
<script src="https://browser.sentry-cdn.com/7.x.x/bundle.min.js"></script>
<script>
  Sentry.init({
    dsn: "your-sentry-dsn",
    environment: "production"
  });
</script>
```

**Option 2: LogRocket**
```javascript
<script src="https://cdn.logrocket.io/LogRocket.min.js"></script>
<script>
  window.LogRocket && window.LogRocket.init('your-app-id');
</script>
```

### Analytics

**Google Analytics 4**
```html
<!-- Add to <head> -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

**Plausible Analytics** (Privacy-friendly)
```html
<script defer data-domain="yourdomain.com" src="https://plausible.io/js/script.js"></script>
```

---

## 🔄 Continuous Deployment

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to Netlify
        uses: nwtgck/actions-netlify@v1.2
        with:
          publish-dir: '.'
          production-deploy: true
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

---

## 🧪 Testing Before Production

### Pre-Deployment Checklist

```bash
# Test authentication flow
1. Sign up new user
2. Verify email
3. Login
4. Logout
5. Password reset

# Test core features
1. Create animal record
2. Add production entry
3. View dashboard charts
4. Export data
5. Test mobile view

# Test permissions
1. Login as admin - verify full access
2. Login as staff - verify restricted access
3. Test RLS policies
```

### Automated Testing

Create a simple test script:

```javascript
// test.js
async function runTests() {
    const tests = [
        { name: 'Config loaded', test: () => typeof SUPABASE_URL !== 'undefined' },
        { name: 'Supabase initialized', test: () => typeof supabase !== 'undefined' },
        { name: 'Auth check', test: async () => {
            const { data } = await supabase.auth.getSession();
            return true; // If no error thrown
        }}
    ];
    
    for (const t of tests) {
        try {
            await t.test();
            console.log(`✅ ${t.name}`);
        } catch (e) {
            console.error(`❌ ${t.name}:`, e);
        }
    }
}
```

---

## 🔧 Troubleshooting Production Issues

### Common Issues

**Issue**: CORS errors
- **Solution**: Add your domain to Supabase allowed origins
  - Go to Supabase → Authentication → URL Configuration
  - Add your production URL

**Issue**: 404 errors on page refresh
- **Solution**: Configure redirects
  - Netlify: Create `_redirects` file with `/* /index.html 200`
  - Vercel: Create `vercel.json` with rewrites config

**Issue**: Environment variables not working
- **Solution**: Rebuild and redeploy after adding env vars

**Issue**: Database connection fails
- **Solution**: Check Supabase project is not paused (free tier)

---

## 📞 Post-Deployment

### Things to Monitor

1. **Performance**
   - Page load times
   - API response times
   - Database query performance

2. **Errors**
   - JavaScript errors
   - Failed API calls
   - Authentication issues

3. **Usage**
   - Daily active users
   - Most used features
   - Browser/device distribution

### Backup Strategy

1. **Database Backups**
   - Supabase Pro: Automatic daily backups
   - Free tier: Manual exports via Supabase dashboard
   
2. **Code Backups**
   - GitHub repository (version control)
   - Local backups

---

## 🎉 Launch Checklist

- [ ] Database migrations run successfully
- [ ] RLS policies tested
- [ ] SSL certificate active (HTTPS)
- [ ] Custom domain configured
- [ ] Error tracking enabled
- [ ] Analytics configured
- [ ] Backup strategy in place
- [ ] Documentation updated
- [ ] Team trained on system
- [ ] Monitoring dashboard set up

---

**Congratulations!** Your Blaze Dairy Management system is now live! 🚀

For support and updates, refer to the main README.md and QUICKSTART.md files.
