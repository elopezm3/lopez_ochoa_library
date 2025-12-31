# Database Backup Documentation

## Overview

The Biblioteca López Ochoa application uses **GitHub Actions** to automatically backup the database to CSV files and store them as GitHub Releases.

## How It Works

1. **Automated Schedule**: Runs every 5 days at midnight UTC
   - **Why every 5 days?** Supabase free tier pauses after 7 days of inactivity. Running every 5 days ensures the database stays active (the backup connection counts as activity).
2. **Manual Trigger**: Can be triggered anytime from GitHub Actions UI
3. **Export Process**: Connects to Supabase and exports all tables (autores, libros, copias) to CSV
4. **Storage**: Creates a ZIP file and uploads as a GitHub Release
5. **Cleanup**: Automatically keeps only the last 10 backups

### Supabase Activity

**Important:** The backup connection to Supabase **counts as activity**, which prevents the database from pausing. By running every 5 days (instead of 7), we ensure there's a safety buffer in case a backup is delayed or fails.

## Setup

### 1. Repository Secrets

The workflow requires two secrets to be configured in GitHub:

Go to: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `RAILS_MASTER_KEY` | Decrypts Rails credentials | Run `cat config/master.key` locally |
| `DATABASE_URL` | Supabase connection string | Use Session Pooler connection string |

**DATABASE_URL Format:**
```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

**Important:** Use the **Session Pooler** connection string (port 6543), not Direct connection, because:
- Render doesn't support IPv6
- Direct connection may resolve to IPv6 addresses

### 2. Workflow File

The workflow is located at: `.github/workflows/backup.yml`

It includes:
- Required permissions (`contents: write`) for creating releases
- Ruby 3.3.2 setup
- Database export via rake task
- ZIP file creation
- GitHub Release creation
- Automatic cleanup of old releases

## Usage

### Manual Backup

1. Go to: **https://github.com/elopezm3/lopez_ochoa_library/actions**
2. Click **"Database Backup"** workflow
3. Click **"Run workflow"** button (top right)
4. Select branch: `main`
5. Click **"Run workflow"**

### Download Backups

1. Go to: **https://github.com/elopezm3/lopez_ochoa_library/releases**
2. Find the backup release (named `backup-YYYYMMDD_HHMMSS`)
3. Download the ZIP file
4. Extract to see the CSV files:
   - `autores.csv`
   - `libros.csv`
   - `copias.csv`

### Automatic Schedule

Backups run automatically every **5 days at 00:00 UTC**. This ensures Supabase stays active (free tier pauses after 7 days of inactivity). No action required.

## Local Backup (Development)

You can also run backups locally for testing:

```bash
# Export to CSV files
rails backup:export_csv

# Files will be in: tmp/backups/YYYYMMDD_HHMMSS/
```

## Restore from Backup

To restore data from a backup:

1. Download the backup ZIP from GitHub Releases
2. Extract the CSV files
3. In Rails console:

```ruby
require 'csv'

# Clear existing data (CAREFUL!)
Copia.destroy_all
Libro.destroy_all
Autor.destroy_all

# Restore Autores
CSV.foreach('path/to/autores.csv', headers: true) do |row|
  Autor.create!(row.to_h)
end

# Restore Libros (skip copy creation)
CSV.foreach('path/to/libros.csv', headers: true) do |row|
  libro = Libro.new(row.to_h)
  libro.skip_copy_creation = true
  libro.save!
end

# Restore Copias
CSV.foreach('path/to/copias.csv', headers: true) do |row|
  Copia.create!(row.to_h)
end
```

## Troubleshooting

### Workflow Fails with 403 Error

**Problem:** "GitHub release failed with status: 403"

**Solution:** Ensure the workflow has write permissions. Check that `.github/workflows/backup.yml` includes:
```yaml
permissions:
  contents: write
```

### Database Connection Error

**Problem:** "Could not connect to database"

**Solution:**
1. Verify `DATABASE_URL` secret is set correctly
2. Ensure you're using Session Pooler connection string (port 6543)
3. Check that Supabase allows connections from GitHub Actions IPs

### CSV Export Fails

**Problem:** "Could not export table"

**Solution:**
1. Check that `csv` gem is in Gemfile
2. Verify database connection is working
3. Check Rails credentials are properly configured

## Backup Retention

- **Keeps:** Last 10 backups
- **Storage:** GitHub Releases (500MB free limit)
- **Format:** ZIP files containing 3 CSV files each
- **Size:** ~50-100KB per backup (very small)

## Related Files

- **Workflow:** `.github/workflows/backup.yml`
- **Rake Task:** `lib/tasks/backup.rake`
- **Documentation:** `BACKUP_PLAN.md` (detailed implementation plan)

## Cost

- **GitHub Actions:** Free (2000 minutes/month)
- **GitHub Releases:** Free (500MB storage)
- **Total Cost:** $0

## Notes

- Backups are stored as **GitHub Releases**, not in the repository itself
- Each backup creates a new release tag: `backup-YYYYMMDD_HHMMSS`
- Old releases are automatically deleted (keeps last 10)
- The workflow uses `GITHUB_TOKEN` which is automatically provided by GitHub Actions

