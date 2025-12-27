class InicioController < ApplicationController
  def index
    @total_books = Libro.count
    @total_authors = Autor.count
    @total_copies = Copia.count
    @loaned_copies = Copia.where.not(prestamo: [nil, '']).count
    @available_copies = @total_copies - @loaned_copies
    @recent_books = Libro.includes(:autor).order(created_at: :desc).limit(5)
    @recent_loans = Copia.includes(libro: :autor).where.not(prestamo: [nil, '']).order(fecha: :desc).limit(5)
  end
end
