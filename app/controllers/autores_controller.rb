class AutoresController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy]

  def index
    @authors = Autor.order(:apellido, :nombre)
  end

  def show
    @books = @author.libros.order(:titulo)
  end

  def new
    @author = Autor.new
  end

  def create
    @author = Autor.new(author_params)
    if @author.save
      redirect_to @author, notice: 'Autor creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @author.update(author_params)
      redirect_to @author, notice: 'Autor actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @author.destroy
    redirect_to autores_path, notice: 'Autor eliminado exitosamente.'
  end

  private

  def set_author
    @author = Autor.find(params[:id])
  end

  def author_params
    params.require(:autor).permit(:nombre, :apellido)
  end
end
