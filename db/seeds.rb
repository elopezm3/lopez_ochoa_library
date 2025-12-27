require 'csv'

puts "Cargando datos desde CSVs..."

# Path to CSV files (adjust if needed)
csv_path = Rails.root.join('..') # Parent directory

# Load Autores
authors_file = csv_path.join('Autores.csv')
if File.exist?(authors_file)
  authors_map = {}
  CSV.foreach(authors_file, headers: true, encoding: 'utf-8') do |row|
    author = Autor.create!(
      nombre: row['Nombre']&.strip,
      apellido: row['Apellido']&.strip
    )
    authors_map[row['id'].to_i] = author.id
  end
  puts "✓ #{Autor.count} autores cargados"
else
  puts "⚠ Archivo Autores.csv no encontrado"
end

# Load Libros
books_file = csv_path.join('Libros.csv')
if File.exist?(books_file)
  books_map = {}
  CSV.foreach(books_file, headers: true, encoding: 'utf-8') do |row|
    author_id = authors_map[row['Autor'].to_i]
    if author_id
      # Skip the auto-creation of copy by using a special method
      book = Libro.new(
        titulo: row['Título']&.strip,
        autor_id: author_id
      )
      book.skip_copy_creation = true
      book.save!
      books_map[row['id'].to_i] = book.id
    end
  end
  puts "✓ #{Libro.count} libros cargados"
else
  puts "⚠ Archivo Libros.csv no encontrado"
end

# Load Copias
copies_file = csv_path.join('Copias.csv')
if File.exist?(copies_file)
  CSV.foreach(copies_file, headers: true, encoding: 'utf-8') do |row|
    book_id = books_map[row['Libro'].to_i]
    if book_id
      Copia.create!(
        libro_id: book_id,
        prestamo: row['Préstamo']&.strip.presence,
        fecha: row['Fecha']&.strip.presence
      )
    end
  end
  puts "✓ #{Copia.count} copias cargadas"
else
  puts "⚠ Archivo Copias.csv no encontrado"
end

puts "\n¡Datos cargados exitosamente!"
puts "  - #{Autor.count} autores"
puts "  - #{Libro.count} libros"
puts "  - #{Copia.count} copias"
