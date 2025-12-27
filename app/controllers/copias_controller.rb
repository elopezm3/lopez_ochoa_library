class CopiasController < ApplicationController
  before_action :set_copy, only: [:show, :edit, :update, :destroy, :loan, :return]

  def index
    @copies = Copia.includes(libro: :autor).order('libros.titulo')
    if params[:estado] == 'disponibles'
      @copies = @copies.where(prestamo: [nil, ''])
    elsif params[:estado] == 'prestadas'
      @copies = @copies.where.not(prestamo: [nil, ''])
    end
  end

  def show
  end

  def new
    @copy = Copia.new
    @copy.libro_id = params[:libro_id] if params[:libro_id]
  end

  def create
    @copy = Copia.new(copy_params)
    if @copy.save
      redirect_to @copy.libro, notice: 'Copia añadida exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @copy.update(copy_params)
      redirect_to @copy.libro, notice: 'Copia actualizada exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    book = @copy.libro
    @copy.destroy
    redirect_to book, notice: 'Copia eliminada exitosamente.'
  end

  def loan
    borrower_name = params[:nombre_prestamo]
    if borrower_name.present?
      @copy.loan!(borrower_name)
      redirect_to @copy.libro, notice: "Libro prestado a #{borrower_name}."
    else
      redirect_to @copy.libro, alert: 'Debe indicar a quién se presta el libro.'
    end
  end

  def return
    @copy.return!
    redirect_to @copy.libro, notice: 'Libro devuelto exitosamente.'
  end

  private

  def set_copy
    @copy = Copia.find(params[:id])
  end

  def copy_params
    params.require(:copia).permit(:libro_id, :prestamo, :fecha)
  end
end
