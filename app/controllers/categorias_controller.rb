class CategoriasController < ApplicationController
  before_action :authenticate_usuario!, except: [:index]
  before_action :set_categoria, only: [:edit, :update, :destroy]
  before_action :authorize_categoria, only: [:edit, :update, :destroy]

  def index
    @categorias = Categoria.all.order(:nome)
  end

  def new
    @categoria = Categoria.new
  end

  def create
    @categoria = Categoria.new(categoria_params)
    
    if @categoria.save
      redirect_to categorias_path, notice: 'Categoria criada com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @categoria.update(categoria_params)
      redirect_to categorias_path, notice: 'Categoria atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @categoria.filmes.any?
      redirect_to categorias_path, alert: 'Não é possível excluir categoria com filmes associados.'
    else
      @categoria.destroy
      redirect_to categorias_path, notice: 'Categoria excluída com sucesso!'
    end
  end

  private

  def set_categoria
    @categoria = Categoria.find(params[:id])
  end

  def categoria_params
    params.require(:categoria).permit(:nome)
  end

  def authorize_categoria
    unless current_usuario.admin? || current_usuario.moderador?
      redirect_to categorias_path, alert: 'Você não tem permissão para realizar esta ação.'
    end
  end
end
