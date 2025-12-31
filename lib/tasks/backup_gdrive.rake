namespace :backup do
  desc "Backup database and upload to Google Drive"
  task to_gdrive: :environment do
    require 'google/apis/drive_v3'
    require 'googleauth'
    
    # Export CSVs first
    Rake::Task['backup:export_csv'].invoke
    
    # Configuration
    folder_id = Rails.application.credentials.dig(:google_drive, :folder_id)
    
    # Get service account and fix private_key newlines
    service_account = Rails.application.credentials.dig(:google_drive, :service_account).deep_dup
    if service_account[:private_key].is_a?(String)
      # Convert escaped \n to actual newlines
      service_account[:private_key] = service_account[:private_key].gsub("\\n", "\n")
    end
    
    # Set up Google Drive client
    drive = Google::Apis::DriveV3::DriveService.new
    drive.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(service_account.to_json),
      scope: Google::Apis::DriveV3::AUTH_DRIVE_FILE
    )
    
    # Find the latest backup folder
    backup_dir = Rails.root.join('tmp', 'backups')
    latest_folder = Dir.glob(backup_dir.join('*')).select { |f| File.directory?(f) }.max_by { |f| File.mtime(f) }
    timestamp = File.basename(latest_folder)
    
    puts "📤 Uploading backup #{timestamp} to Google Drive..."
    
    # Upload each CSV directly to the shared folder (no subfolder creation)
    # Files are named with timestamp prefix: 20251231_021419_autores.csv
    Dir.glob("#{latest_folder}/*.csv").each do |file_path|
      original_name = File.basename(file_path)
      timestamped_name = "#{timestamp}_#{original_name}"
      
      file_metadata = Google::Apis::DriveV3::File.new(
        name: timestamped_name,
        parents: [folder_id]  # Upload directly to the user's shared folder
      )
      drive.create_file(
        file_metadata,
        upload_source: file_path,
        content_type: 'text/csv'
      )
      puts "  ✓ Uploaded #{timestamped_name}"
    end
    
    # Clean up old backups (keep last 10 sets = 30 files for 3 tables)
    cleanup_old_backups(drive, folder_id, 10)
    
    # Clean up local backup
    FileUtils.rm_rf(latest_folder)
    
    puts "\n✅ Backup complete!"
  end
  
  def cleanup_old_backups(drive, folder_id, keep_backup_sets)
    # List all CSV files in the backup folder, sorted by creation time (newest first)
    response = drive.list_files(
      q: "'#{folder_id}' in parents and mimeType = 'text/csv'",
      order_by: 'createdTime desc',
      fields: 'files(id, name, createdTime)'
    )
    
    files = response.files
    
    # Group files by timestamp prefix (e.g., "20251231_021419")
    grouped = files.group_by { |f| f.name.match(/^(\d{8}_\d{6})_/)&.captures&.first }
    grouped.delete(nil)  # Remove files without timestamp prefix
    
    # Sort backup sets by timestamp (newest first)
    sorted_timestamps = grouped.keys.sort.reverse
    
    if sorted_timestamps.length > keep_backup_sets
      timestamps_to_delete = sorted_timestamps[keep_backup_sets..-1]
      timestamps_to_delete.each do |timestamp|
        grouped[timestamp].each do |file|
          drive.delete_file(file.id)
        end
        puts "🗑️  Deleted old backup: #{timestamp}"
      end
    end
  end
end