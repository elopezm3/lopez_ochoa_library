# Render Deployment Guide

This guide will help you deploy the Biblioteca López Ochoa application to Render.

## Prerequisites

Before deploying, ensure you have:
- [ ] A GitHub account with the repository pushed
- [ ] A Render account (sign up at [render.com](https://render.com))
- [ ] Supabase database set up and connection string ready
- [ ] Rails credentials configured with your database URL

---

## Step 1: Prepare Your Repository

Ensure your repository is up to date on GitHub:

```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

---

## Step 2: Create a Render Account

1. Go to [https://render.com](https://render.com)
2. Click "Get Started for Free"
3. Sign up with GitHub (recommended for easy repo access)

---

## Step 3: Create a New Web Service

1. From your Render dashboard, click **"New +"** → **"Web Service"**
2. Connect your GitHub account if not already connected
3. Find and select the **`lopez_ochoa_library`** repository
4. Click **"Connect"**

---

## Step 4: Configure the Web Service

Fill in the following settings:

### Basic Settings

| Setting | Value |
|---------|-------|
| **Name** | `lopez-ochoa-library` (or your preferred name) |
| **Region** | Choose closest to your users (e.g., Oregon for US West) |
| **Branch** | `main` |
| **Runtime** | `Ruby` |

### Build & Deploy Settings

| Setting | Value |
|---------|-------|
| **Build Command** | `bundle install && rails assets:precompile && rails db:migrate` |
| **Start Command** | `bundle exec puma -C config/puma.rb` |

---

## Step 5: Set Environment Variables

Click **"Advanced"** to expand environment variable settings, then add:

### Required Environment Variables

| Key | Value | Description |
|-----|-------|-------------|
| `RAILS_MASTER_KEY` | *(copy from `config/master.key`)* | Decrypts Rails credentials |
| `RAILS_ENV` | `production` | Production environment |
| `RAILS_SERVE_STATIC_FILES` | `true` | Serve assets from Rails |

### Getting Your RAILS_MASTER_KEY

Run this in your terminal to copy the master key:

```bash
cat config/master.key
```

Copy the output and paste it as the value for `RAILS_MASTER_KEY`.

### Optional: DATABASE_URL Override

If you prefer to use an environment variable instead of Rails credentials for the database:

| Key | Value |
|-----|-------|
| `DATABASE_URL` | `postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres` |

**Important:** Use the **Session Pooler** connection string (port 6543) from Supabase, not Direct connection. Render doesn't support IPv6 and Direct connection may resolve to IPv6.

**Note:** If `DATABASE_URL` is set, it takes priority over Rails credentials.

---

## Step 6: Select Instance Type

Choose your plan:

| Plan | Price | Best For |
|------|-------|----------|
| **Free** | $0/month | Testing, personal projects |
| **Starter** | $7/month | Small production apps |
| **Standard** | $25/month | Production apps with more traffic |

**Note:** Free tier has limitations:
- Spins down after 15 minutes of inactivity
- Limited to 750 hours/month
- Slower cold starts

---

## Step 7: Deploy

1. Review all settings
2. Click **"Create Web Service"**
3. Wait for the build and deployment to complete (5-10 minutes)

Render will:
1. Clone your repository
2. Install Ruby and dependencies
3. Run `bundle install`
4. Precompile assets
5. Run database migrations
6. Start the Puma server

---

## Step 8: Verify Deployment

Once deployed:

1. Click on your service URL: **https://lopez-ochoa-library.onrender.com/**
2. Verify the app loads correctly
3. Test basic functionality (view books, authors, etc.)

---

## Step 9: Set Up Auto-Deploy (Optional but Recommended)

Render auto-deploys on every push to `main` by default. To configure:

1. Go to your service settings
2. Under **"Build & Deploy"**, find **"Auto-Deploy"**
3. Enable or disable as needed

---

## Troubleshooting

### Build Fails: "Could not find pg"

Make sure `pg` gem is in your Gemfile:
```ruby
gem "pg", "~> 1.5"
```

### Database Connection Error: "Network is unreachable" (IPv6 Error)

If you see an error like:
```
connection to server at "2600:1f13:..." port 5432 failed: Network is unreachable
```

**This is an IPv6 issue.** Render doesn't support IPv6, but Supabase's "Direct connection" resolves to IPv6.

**Solution: Use Supabase Session Pooler instead:**

1. In Supabase Dashboard → **Settings** → **Database**
2. In **Connection string** section, select **"Session pooler"** (not Direct connection)
3. Copy the new URI - it looks like:
   ```
   postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
   ```
   
   Note the differences:
   - Username: `postgres.[PROJECT-REF]` (includes project ref)
   - Host: `aws-0-[REGION].pooler.supabase.com` (pooler host)
   - Port: `6543` (not 5432)

4. Update Rails credentials:
   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```
   ```yaml
   database:
     url: postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
   ```

5. Commit, push, and redeploy

### Other Database Connection Errors

1. Verify `RAILS_MASTER_KEY` is set correctly in Render
2. Check your Supabase connection string in credentials
3. Ensure Supabase allows connections from any IP

### Assets Not Loading

Ensure these are set:
```
RAILS_SERVE_STATIC_FILES=true
RAILS_ENV=production
```

### Migrations Fail

Check your migration files for SQLite-specific syntax. PostgreSQL may need adjustments.

### Slow First Request (Free Tier)

Free tier apps spin down after 15 minutes of inactivity. The first request after spin-down takes 30-60 seconds. Consider upgrading to Starter ($7/month) for always-on.

---

## Monitoring & Logs

### View Logs

1. Go to your service in Render dashboard
2. Click **"Logs"** tab
3. View real-time logs or search historical logs

### Check Health

1. Go to **"Events"** tab to see deployment history
2. Monitor **"Metrics"** for CPU/memory usage

---

## Custom Domain (Optional)

To use your own domain:

1. Go to your service settings
2. Click **"Custom Domains"**
3. Add your domain (e.g., `library.yourdomain.com`)
4. Configure DNS:
   - Add a CNAME record pointing to your Render URL
   - Or use Render's nameservers

Render automatically provisions SSL certificates.

---

## Updating Your App

To deploy updates:

1. Make changes locally
2. Commit and push:
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin main
   ```
3. Render automatically rebuilds and deploys

---

## Cost Summary

| Service | Monthly Cost |
|---------|-------------|
| Render Free | $0 |
| Render Starter | $7 |
| Supabase Free | $0 |
| **Total (Free)** | **$0** |
| **Total (Starter)** | **$7** |

---

## Quick Reference

| Task | Command/Location |
|------|-----------------|
| View master key | `cat config/master.key` |
| Edit credentials | `EDITOR="code --wait" rails credentials:edit` |
| Check production logs | Render Dashboard → Logs |
| Run console | Not available on free tier; use `render console` on paid tiers |
| Manual deploy | Render Dashboard → Manual Deploy |

---

## Next Steps

After successful deployment:

1. [ ] Test all CRUD operations
2. [ ] Seed production database (if needed)
3. [ ] Set up custom domain (optional)
4. [ ] Configure monitoring alerts (optional)
5. [ ] Share the URL with users!

---

## Seeding Production Database

If you need to seed the production database:

1. Go to Render Dashboard → Your Service
2. Click **"Shell"** tab (paid tiers only)
3. Run:
   ```bash
   rails db:seed
   ```

**For free tier:** You'll need to seed data manually through the app or use a database migration with initial data.

