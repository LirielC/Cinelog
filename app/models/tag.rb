class Tag < ApplicationRecord
  has_and_belongs_to_many :filmes
  
  validates :nome, presence: true, uniqueness: { case_sensitive: false }
  
  before_validation :normalizar_nome
  
  private
  
  def normalizar_nome
    self.nome = nome.strip.downcase if nome.present?
  end
end
