class LibrosController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Libro.includes(:autor, :copias).joins(:autor)
    
    # Apply search filter
    if params[:buscar].present?
      search_term = "%#{params[:buscar]}%"
      @books = @books.where(
        "libros.titulo LIKE ? OR autores.nombre LIKE ? OR autores.apellido LIKE ?",
        search_term, search_term, search_term
      )
    end
    
    # Apply sorting
    @sort_column = params[:sort] || 'autor'
    @sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    
    case @sort_column
    when 'titulo'
      @books = @sort_direction == 'asc' ? 
        @books.order('libros.titulo ASC') : 
        @books.order('libros.titulo DESC')
    when 'autor'
      if @sort_direction == 'asc'
        @books = @books.order('autores.apellido ASC, autores.nombre ASC')
      else
        @books = @books.order('autores.apellido DESC, autores.nombre DESC')
      end
    when 'copias'
      @books = @books.left_joins(:copias)
                     .group('libros.id, autores.apellido, autores.nombre')
      @books = @sort_direction == 'asc' ?
        @books.order('COUNT(copias.id) ASC') :
        @books.order('COUNT(copias.id) DESC')
    else
      @books = @books.order('autores.apellido, autores.nombre, libros.titulo')
    end
  end

  def show
    @copies = @book.copias
  end

  def new
    @book = Libro.new
  end

  def create
    @book = Libro.new(book_params)
    if @book.save
      redirect_to @book, notice: 'Libro creado exitosamente. Se ha añadido una copia automáticamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: 'Libro actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to libros_path, notice: 'Libro eliminado exitosamente.'
  end

  private

  def set_book
    @book = Libro.find(params[:id])
  end

  def book_params
    params.require(:libro).permit(:titulo, :autor_id)
  end
end
