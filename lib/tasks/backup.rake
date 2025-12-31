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