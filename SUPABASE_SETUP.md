# Supabase Database Setup Guide

This guide will help you configure Supabase as the database for the Biblioteca López Ochoa application.

## Step 1: Create a Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Fill in your project details:
   - **Name**: lopez-ochoa-library (or any name you prefer)
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose the closest region
5. Wait for the project to be created (takes a few minutes)

## Step 2: Get Your Connection Details

1. In your Supabase project dashboard, go to **Settings** → **Database**
2. Scroll down to **Connection string** section
3. Choose the appropriate connection type:

### For Local Development: Use "Direct connection"
```
postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
```

### For Render (or other IPv4-only hosts): Use "Session pooler"

**Important:** Render doesn't support IPv6, and Direct connection may resolve to IPv6. Use Session pooler instead:

```
postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

Note the differences:
- **Username**: `postgres.[PROJECT-REF]` (includes your project reference)
- **Host**: `aws-0-[REGION].pooler.supabase.com` (pooler host, not db.xxx)
- **Port**: `6543` (not 5432)

4. Copy the appropriate **URI** connection string based on your deployment target

## Step 3: Configure Your Rails App with Rails Credentials

This application uses **Rails Credentials** to store the database connection string. This is encrypted and secure, and works for both development and production.

### Setting Up Rails Credentials

1. Edit Rails credentials:
   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```
   
   **Note:** Replace `code` with your preferred editor:
   - VS Code: `code --wait`
   - Vim: `vim`
   - Nano: `nano`
   - Mac default: `open -a TextEdit`

2. Add your database URL to the credentials file:
   ```yaml
   database:
     url: postgresql://postgres:[YOUR-PASSWORD]@[PROJECT-REF].supabase.co:5432/postgres
   ```
   
   Replace:
   - `[YOUR-PASSWORD]` with your actual Supabase database password
   - `[PROJECT-REF]` with your actual project reference (found in the Supabase connection string)

3. Save and close the file. Rails will automatically encrypt it.

### Example Credentials File

Your `config/credentials.yml.enc` (encrypted) should contain something like:
```yaml
database:
  url: postgresql://postgres:mypassword123@abcdefghijklmnop.supabase.co:5432/postgres
```

### How It Works

- The credentials are stored in `config/credentials.yml.enc` (encrypted)
- The master key is in `config/master.key` (NEVER commit this file!)
- `config/database.yml` automatically reads from credentials
- Works the same way in development and production

### For Production Deployment

**Option 1:** Use Rails credentials (recommended)
- Set the `RAILS_MASTER_KEY` environment variable in your hosting platform
- The value is in `config/master.key` (copy it securely)

**Option 2:** Use `DATABASE_URL` environment variable
- Some hosting platforms (Heroku, Railway, Render) prefer this
- Set `DATABASE_URL` in your platform's environment variables
- The app will use this if available, otherwise falls back to credentials

## Step 4: Install Dependencies and Setup Database

1. Install the PostgreSQL gem:
   ```bash
   bundle install
   ```

2. Run database migrations:
   ```bash
   rails db:migrate
   ```

3. (Optional) Seed the database:
   ```bash
   rails db:seed
   ```

## Step 5: Verify Connection

Test the connection by running:
```bash
rails db:version
```

If it shows the database version, you're connected!

## Security Notes

- **NEVER commit `config/master.key`** - this decrypts Rails credentials (already in `.gitignore`)
- The `config/credentials.yml.enc` file IS safe to commit (it's encrypted)
- For production, set `RAILS_MASTER_KEY` environment variable with the value from `config/master.key`
- Consider using Supabase's connection pooling for production

## Troubleshooting

### "prepared statement does not exist" Error

If you see an error like:
```
PG::InvalidSqlStatementName: ERROR: prepared statement "a2" does not exist
```

This happens when using Supabase's Session Pooler (transaction mode) with Rails prepared statements. The fix is already applied in `config/database.yml`:

```yaml
production:
  prepared_statements: false
```

### Connection Refused
- Check that your IP is allowed in Supabase (Settings → Database → Connection Pooling)
- Verify your password is correct
- Make sure the project reference is correct

### SSL Required
If you get SSL errors, add `?sslmode=require` to your connection string:
```
DATABASE_URL=postgresql://postgres:[PASSWORD]@[PROJECT-REF].supabase.co:5432/postgres?sslmode=require
```

### Migration Issues
If migrations fail, make sure you're using the correct database:
```bash
rails db:migrate:status
```

## Production Deployment

For production, set the `DATABASE_URL` environment variable in your hosting platform (Heroku, Railway, Render, etc.) with your Supabase connection string.


