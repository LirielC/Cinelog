class Categoria < ApplicationRecord
  self.table_name = 'categorias'
  
  has_and_belongs_to_many :filmes

  validates :nome, presence: true, uniqueness: true
end
