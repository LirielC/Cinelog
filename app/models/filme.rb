class Filme < ApplicationRecord
  include PgSearch::Model

  belongs_to :usuario, optional: true
  has_many :comentarios, dependent: :destroy
  has_and_belongs_to_many :categorias
  has_and_belongs_to_many :tags

  has_one_attached :poster

  # Busca full-text com pg_search
  pg_search_scope :buscar_por_texto,
                  against: [:titulo, :sinopse, :diretor],
                  using: {
                    tsearch: {
                      prefix: true,
                      any_word: true
                    }
                  }

  validates :titulo, presence: true
  validates :ano_lancamento, numericality: { only_integer: true, greater_than: 1800 }, allow_nil: true
  validates :duracao_minutos, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  
  # Validação de duplicação: verifica título + ano
  validate :verificar_filme_duplicado, on: :create

  default_scope -> { order(created_at: :desc) }

  # Método para verificar se já existe filme similar
  def verificar_filme_duplicado
    return if titulo.blank?
    
    # Normalizar título para comparação (remove acentos, case insensitive)
    titulo_normalizado = I18n.transliterate(titulo.downcase.strip)
    
    filmes_similares = Filme.where(
      "LOWER(TRIM(titulo)) = ? AND ano_lancamento = ?",
      titulo.downcase.strip,
      ano_lancamento
    )
    
    # Se encontrou filme com mesmo título e ano
    if filmes_similares.exists?
      errors.add(:titulo, :duplicado, titulo: titulo, ano: ano_lancamento)
    end
  end
  
  # Método para buscar duplicatas potenciais (usado no frontend)
  def self.buscar_duplicatas_potenciais(titulo, ano = nil)
    return none if titulo.blank?
    
    query = where("LOWER(titulo) LIKE ?", "%#{titulo.downcase}%")
    query = query.where(ano_lancamento: ano) if ano.present?
    query.limit(5)
  end
  
  # Retorna o título traduzido baseado no locale atual
  def titulo_traduzido(locale = I18n.locale)
    Rails.logger.info "=== TITULO TRANSLATION DEBUG ==="
    Rails.logger.info "Filme: #{titulo}, TMDB ID: #{tmdb_id}, Locale: #{locale}"
    
    return titulo if locale.to_s == 'pt-BR' || tmdb_id.blank?
    
    @traducoes ||= {}
    @traducoes[locale] ||= begin
      idioma = locale.to_s == 'en' ? 'en-US' : locale.to_s
      Rails.logger.info "Buscando tradução do título para idioma: #{idioma}"
      
      traducao = ServicoTmdb.buscar_traducao(tmdb_id, idioma)
      Rails.logger.info "Resposta API (título): #{traducao.inspect}"
      
      resultado = traducao&.dig(:titulo) || titulo
      Rails.logger.info "Título retornado: #{resultado}"
      resultado
    rescue => e
      Rails.logger.error "Erro na tradução do título: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      titulo
    end
  end
  
  # Retorna a sinopse traduzida baseada no locale atual
  def sinopse_traduzida(locale = I18n.locale)
    Rails.logger.info "=== SINOPSE TRANSLATION DEBUG ==="
    Rails.logger.info "Filme: #{titulo}, TMDB ID: #{tmdb_id}, Locale: #{locale}"
    
    return sinopse if locale.to_s == 'pt-BR' || tmdb_id.blank?
    
    @traducoes ||= {}
    @traducoes[locale] ||= begin
      idioma = locale.to_s == 'en' ? 'en-US' : locale.to_s
      Rails.logger.info "Buscando tradução para idioma: #{idioma}"
      
      traducao = ServicoTmdb.buscar_traducao(tmdb_id, idioma)
      Rails.logger.info "Resposta API: #{traducao.inspect}"
      
      resultado = traducao&.dig(:sinopse) || sinopse
      Rails.logger.info "Sinopse retornada (primeiros 100 chars): #{resultado&.slice(0,100)}"
      resultado
    rescue => e
      Rails.logger.error "Erro na tradução: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      sinopse
    end
  end
end
