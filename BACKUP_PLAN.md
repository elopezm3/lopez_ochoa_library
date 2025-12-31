# Backup Plan for Biblioteca López Ochoa

Since Supabase Free tier doesn't include automated backups, this document outlines backup strategies for the library database.

## Current Data Size (Approximate)
- **Libros**: ~322 records
- **Autores**: ~245 records
- **Copias**: ~324 records
- **Total**: ~900 records (very small, any solution will work)

---

## ✅ Implemented Solution: GitHub Actions + Releases

Backups are automated using **GitHub Actions** and stored as **GitHub Releases**.

### How It Works
1. GitHub Actions runs weekly (Sunday at midnight UTC)
2. Connects to Supabase and exports all tables to CSV
3. Creates a ZIP file with all CSVs
4. Uploads as a GitHub Release
5. Automatically deletes old releases (keeps last 10)

### Manual Backup
You can trigger a backup manually:
1. Go to your repo on GitHub
2. Click **Actions** tab
3. Select **Database Backup** workflow
4. Click **Run workflow** → **Run workflow**

### Download Backups
1. Go to your repo on GitHub
2. Click **Releases** (right sidebar)
3. Download the ZIP file from any backup

---

## Setup Instructions (One-Time)

### Step 1: Add Repository Secrets

Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `RAILS_MASTER_KEY` | Copy from `config/master.key` |
| `DATABASE_URL` | Your Supabase Session Pooler connection string |

**Get RAILS_MASTER_KEY:**
```bash
cat config/master.key
```

**DATABASE_URL format (use Session Pooler):**
```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

### Step 2: Push the Workflow

```bash
git add .github/workflows/backup.yml
git commit -m "Add automated backup workflow"
git push
```

### Step 3: Test It

1. Go to GitHub → Actions → Database Backup
2. Click "Run workflow"
3. Check Releases for the backup

---

## Option Comparison

| Option | Complexity | Cost | Automation | Best For |
|--------|------------|------|------------|----------|
| **A. GitHub Actions** ✅ | Low | Free | Yes | **Current solution** |
| **B. Google Drive (CSV)** | Medium | Free* | Yes | *Doesn't work with service accounts* |
| **C. Email CSV** | Low | Free* | Yes | Simplest automated |
| **D. Local Rake Task** | Very Low | Free | Manual | Quick manual backups |
| **E. S3/R2/B2** | Medium | Free/Cheap | Yes | Scalable, professional |

---

## Alternative: Local Rake Task (Manual Backups)

This is the best balance of simplicity, reliability, and features for your use case.

### Why Google Drive?
- ✅ Free 15GB storage (way more than you'll ever need)
- ✅ Easy to view/download files
- ✅ Can share with others
- ✅ Keeps file history
- ✅ Works with service accounts (no manual auth needed)

### Implementation Overview

1. Create a Rails rake task to export tables as CSV
2. Set up Google Drive API with a service account
3. Upload CSVs to a dedicated backup folder
4. Delete old backups (keep last 10)
5. Schedule with cron or Render Cron Jobs

---

## Step-by-Step Implementation

### Step 1: Create the Backup Rake Task

Create `lib/tasks/backup.rake`:

```ruby
namespace :backup do
  desc "Export all tables to CSV files"
  task export_csv: :environment do
    require 'csv'
    
    backup_dir = Rails.root.join('tmp', 'backups')
    FileUtils.mkdir_p(backup_dir)
    
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_folder = backup_dir.join(timestamp)
    FileUtils.mkdir_p(backup_folder)
    
    # Export Autores
    CSV.open(backup_folder.join('autores.csv'), 'wb') do |csv|
      csv << ['id', 'nombre', 'apellido', 'created_at', 'updated_at']
      Autor.find_each do |autor|
        csv << [autor.id, autor.nombre, autor.apellido, autor.created_at, autor.updated_at]
      end
    end
    puts "✓ Exported #{Autor.count} autores"
    
    # Export Libros
    CSV.open(backup_folder.join('libros.csv'), 'wb') do |csv|
      csv << ['id', 'titulo', 'autor_id', 'created_at', 'updated_at']
      Libro.find_each do |libro|
        csv << [libro.id, libro.titulo, libro.autor_id, libro.created_at, libro.updated_at]
      end
    end
    puts "✓ Exported #{Libro.count} libros"
    
    # Export Copias
    CSV.open(backup_folder.join('copias.csv'), 'wb') do |csv|
      csv << ['id', 'libro_id', 'prestamo', 'fecha', 'created_at', 'updated_at']
      Copia.find_each do |copia|
        csv << [copia.id, copia.libro_id, copia.prestamo, copia.fecha, copia.created_at, copia.updated_at]
      end
    end
    puts "✓ Exported #{Copia.count} copias"
    
    puts "\n📁 Backup saved to: #{backup_folder}"
    backup_folder.to_s
  end
  
  desc "Create a ZIP of the backup"
  task create_zip: :environment do
    require 'zip'
    
    backup_dir = Rails.root.join('tmp', 'backups')
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    
    # First export CSVs
    Rake::Task['backup:export_csv'].invoke
    
    # Find the latest backup folder
    latest_folder = Dir.glob(backup_dir.join('*')).max_by { |f| File.mtime(f) }
    
    zip_path = "#{latest_folder}.zip"
    
    Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      Dir.glob("#{latest_folder}/*.csv").each do |file|
        zipfile.add(File.basename(file), file)
      end
    end
    
    puts "📦 ZIP created: #{zip_path}"
    zip_path
  end
end
```

### Step 2: Add Required Gems

Add to `Gemfile`:

```ruby
# For creating ZIP files
gem 'rubyzip', require: 'zip'

# For Google Drive API
gem 'google-apis-drive_v3'
```

Run:
```bash
bundle install
```

### Step 3: Set Up Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (e.g., "lopez-ochoa-backups")
3. Enable the **Google Drive API**:
   - Go to "APIs & Services" → "Library"
   - Search for "Google Drive API"
   - Click "Enable"

### Step 4: Create a Service Account

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "Service Account"
3. Name it (e.g., "backup-service")
4. Click "Create and Continue"
5. Skip the optional steps, click "Done"
6. Click on the service account you just created
7. Go to "Keys" tab → "Add Key" → "Create new key"
8. Select "JSON" and click "Create"
9. Save the downloaded JSON file securely

### Step 5: Create a Shared Folder in Google Drive

1. Go to [Google Drive](https://drive.google.com/)
2. Create a new folder: "Lopez Ochoa Backups"
3. Right-click → "Share"
4. Add the service account email (from the JSON file, looks like: `backup-service@project-id.iam.gserviceaccount.com`)
5. Give it "Editor" access
6. Copy the folder ID from the URL (the long string after `/folders/`)

### Step 6: Add Google Drive Upload to Rake Task

Create `lib/tasks/backup_gdrive.rake`:

```ruby
namespace :backup do
  desc "Backup database and upload to Google Drive"
  task to_gdrive: :environment do
    require 'google/apis/drive_v3'
    require 'googleauth'
    
    # Export CSVs first
    Rake::Task['backup:export_csv'].invoke
    
    # Configuration
    folder_id = Rails.application.credentials.dig(:google_drive, :folder_id)
    
    # Set up Google Drive client
    drive = Google::Apis::DriveV3::DriveService.new
    drive.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(Rails.application.credentials.dig(:google_drive, :service_account).to_json),
      scope: Google::Apis::DriveV3::AUTH_DRIVE_FILE
    )
    
    # Find the latest backup folder
    backup_dir = Rails.root.join('tmp', 'backups')
    latest_folder = Dir.glob(backup_dir.join('*')).select { |f| File.directory?(f) }.max_by { |f| File.mtime(f) }
    folder_name = File.basename(latest_folder)
    
    # Create a folder in Google Drive for this backup
    folder_metadata = Google::Apis::DriveV3::File.new(
      name: folder_name,
      mime_type: 'application/vnd.google-apps.folder',
      parents: [folder_id]
    )
    gdrive_folder = drive.create_file(folder_metadata, fields: 'id')
    puts "📁 Created Google Drive folder: #{folder_name}"
    
    # Upload each CSV
    Dir.glob("#{latest_folder}/*.csv").each do |file_path|
      file_metadata = Google::Apis::DriveV3::File.new(
        name: File.basename(file_path),
        parents: [gdrive_folder.id]
      )
      drive.create_file(
        file_metadata,
        upload_source: file_path,
        content_type: 'text/csv'
      )
      puts "  ✓ Uploaded #{File.basename(file_path)}"
    end
    
    # Clean up old backups (keep last 10)
    cleanup_old_backups(drive, folder_id, 10)
    
    # Clean up local backup
    FileUtils.rm_rf(latest_folder)
    
    puts "\n✅ Backup complete!"
  end
  
  def cleanup_old_backups(drive, folder_id, keep_count)
    # List all folders in the backup folder
    response = drive.list_files(
      q: "'#{folder_id}' in parents and mimeType = 'application/vnd.google-apps.folder'",
      order_by: 'createdTime desc',
      fields: 'files(id, name, createdTime)'
    )
    
    folders = response.files
    
    if folders.length > keep_count
      folders_to_delete = folders[keep_count..-1]
      folders_to_delete.each do |folder|
        drive.delete_file(folder.id)
        puts "🗑️  Deleted old backup: #{folder.name}"
      end
    end
  end
end
```

### Step 7: Add Credentials

Add to Rails credentials:
```bash
EDITOR="code --wait" rails credentials:edit
```

Add:
```yaml
google_drive:
  folder_id: "YOUR_FOLDER_ID_HERE"
  service_account:
    type: "service_account"
    project_id: "your-project-id"
    private_key_id: "..."
    private_key: "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
    client_email: "backup-service@your-project.iam.gserviceaccount.com"
    client_id: "..."
    auth_uri: "https://accounts.google.com/o/oauth2/auth"
    token_uri: "https://oauth2.googleapis.com/token"
    # ... rest of the service account JSON
```

### Step 8: Test Locally

```bash
rails backup:export_csv      # Test CSV export
rails backup:to_gdrive       # Test full backup to Google Drive
```

### Step 9: Schedule Automated Backups

#### Option A: Render Cron Jobs (Recommended for your setup)

1. Go to Render Dashboard
2. Create a new "Cron Job"
3. Connect to the same repository
4. Configure:
   - **Name**: `lopez-ochoa-backup`
   - **Schedule**: `0 0 * * 0` (weekly on Sunday at midnight)
   - **Command**: `bundle exec rails backup:to_gdrive`
5. Add the same environment variables as your web service

#### Option B: GitHub Actions

Create `.github/workflows/backup.yml`:

```yaml
name: Database Backup

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  workflow_dispatch:  # Allow manual trigger

jobs:
  backup:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3.2'
          bundler-cache: true
      
      - name: Run backup
        env:
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
          RAILS_ENV: production
        run: |
          bundle exec rails backup:to_gdrive
```

---

## Alternative: Option E - Simple Local Backup (Quickest to Implement)

If you want something working immediately without Google API setup:

### Quick Rake Task

Create `lib/tasks/backup.rake`:

```ruby
namespace :backup do
  desc "Export all tables to CSV files in tmp/backups"
  task export: :environment do
    require 'csv'
    
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_dir = Rails.root.join('tmp', 'backups', timestamp)
    FileUtils.mkdir_p(backup_dir)
    
    {
      'autores' => Autor,
      'libros' => Libro,
      'copias' => Copia
    }.each do |name, model|
      CSV.open(backup_dir.join("#{name}.csv"), 'wb') do |csv|
        csv << model.column_names
        model.find_each do |record|
          csv << model.column_names.map { |col| record.send(col) }
        end
      end
      puts "✓ Exported #{model.count} #{name}"
    end
    
    puts "\n📁 Backup saved to: #{backup_dir}"
  end
end
```

Then manually run and download:
```bash
rails backup:export
# Download from tmp/backups/TIMESTAMP/
```

---

## Restore Process

To restore from a backup:

```ruby
# In rails console
require 'csv'

# Clear existing data (careful!)
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

---

## Recommended Implementation Order

1. **Start with Option E** (local rake task) - get it working today
2. **Upgrade to Option B** (Google Drive) when you have time for API setup
3. **Add scheduling** via Render Cron Jobs or GitHub Actions

---

## Backup Checklist

- [ ] Step 1: Create basic rake task (`lib/tasks/backup.rake`)
- [ ] Step 2: Add `rubyzip` gem (optional, for ZIP files)
- [ ] Step 3: Test local backup works
- [ ] Step 4: Set up Google Cloud project
- [ ] Step 5: Create service account and get JSON key
- [ ] Step 6: Create shared folder in Google Drive
- [ ] Step 7: Add `google-apis-drive_v3` gem
- [ ] Step 8: Create Google Drive upload rake task
- [ ] Step 9: Add credentials to Rails
- [ ] Step 10: Test Google Drive backup
- [ ] Step 11: Set up scheduled backups (Render Cron or GitHub Actions)

---

## Cost Summary

| Service | Cost |
|---------|------|
| Google Drive (15GB free) | $0 |
| Render Cron Jobs | $0 (included) |
| GitHub Actions | $0 (2000 min/month free) |
| **Total** | **$0** |

