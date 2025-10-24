class Comentario < ApplicationRecord
  belongs_to :filme
  belongs_to :usuario, optional: true

  validates :conteudo, presence: true, length: { minimum: 3, maximum: 1000 }
  
  # Se não estiver logado (usuário anônimo), não precisa do nome_autor
  # (ficará como "Anônimo" na view)
  # validates :nome_autor, presence: true, unless: -> { usuario.present? }
  
  # Método auxiliar para exibir o nome do autor
  def nome_exibicao
    if usuario.present?
      nome_autor.presence || usuario.nome || usuario.email
    else
      nome_autor.presence || 'Anônimo'
    end
  end
end
