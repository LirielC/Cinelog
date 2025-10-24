class FilmesController < ApplicationController
  before_action :authenticate_usuario!, except: [:index, :show, :buscar, :demo_button]
  before_action :set_filme, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: [:index, :show, :buscar, :demo_button]

  def index
    # SOLUÇÃO: Força 6 filmes por página usando limit direto no ActiveRecord
    @pagy, @filmes = pagy(Filme.reorder(ano_lancamento: :desc, created_at: :desc), limit: 6, items: 6)
    @filmes_destaque = Filme.reorder(ano_lancamento: :desc, created_at: :desc).limit(10)
  end

  def show
    @comentarios = @filme.comentarios.order(created_at: :desc)
  end

  def new
    @filme = current_usuario.filmes.build
    authorize @filme
  end

  def create
    @filme = current_usuario.filmes.build(filme_params)
    authorize @filme
    
    # Associar categorias se fornecidas
    if params[:filme][:categorias].present?
      @filme.categoria_ids = params[:filme][:categorias].reject(&:blank?)
    end
    
    # Processar tags
    processar_tags(@filme, params[:filme][:tags_string]) if params[:filme][:tags_string].present?
    
    if @filme.save
      redirect_to @filme, notice: 'Filme criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @filme
  end

  def update
    authorize @filme
    
    # Processar tags
    processar_tags(@filme, params[:filme][:tags_string]) if params[:filme][:tags_string].present?
    
    if @filme.update(filme_params)
      redirect_to @filme, notice: 'Filme atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    authorize @filme
    @filme.destroy
    redirect_to filmes_path, notice: 'Filme removido.'
  end

  def buscar
    @query = params[:q]
    
    scope = if @query.present?
              Filme.buscar_por_texto(@query).reorder(ano_lancamento: :desc, created_at: :desc)
            else
              Filme.reorder(ano_lancamento: :desc, created_at: :desc)
            end
    
    @pagy, @filmes = pagy(scope, items: 12)
  end

  # Endpoint AJAX para verificar duplicatas em tempo real
  def verificar_duplicata
    titulo = params[:titulo]
    ano = params[:ano_lancamento]
    
    if titulo.present?
      duplicatas = Filme.buscar_duplicatas_potenciais(titulo, ano)
      render json: {
        encontrou_duplicatas: duplicatas.any?,
        filmes: duplicatas.map { |f| 
          { 
            id: f.id, 
            titulo: f.titulo, 
            ano_lancamento: f.ano_lancamento,
            diretor: f.diretor,
            url: filme_path(f)
          } 
        }
      }
    else
      render json: { encontrou_duplicatas: false, filmes: [] }
    end
  end

  # Página de demonstração dos botões 3D
  def demo_button
  end

  private

  def set_filme
    @filme = Filme.find(params[:id])
  end

  def filme_params
    params.require(:filme).permit(:titulo, :sinopse, :ano_lancamento, :duracao_minutos, :diretor, :poster, categoria_ids: [])
  end
  
  def processar_tags(filme, tags_string)
    return if tags_string.blank?
    
    # Limpar tags antigas
    filme.tags.clear
    
    # Processar novas tags (separadas por vírgula ou espaço)
    tags_nomes = tags_string.split(/[,\s]+/).map(&:strip).reject(&:blank?).uniq
    
    tags_nomes.each do |tag_nome|
      tag = Tag.find_or_create_by(nome: tag_nome.downcase)
      filme.tags << tag unless filme.tags.include?(tag)
    end
  end
end
