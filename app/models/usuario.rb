class Usuario < ApplicationRecord
  # Devise modules - adicionar conforme necessidade
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :filmes, dependent: :nullify
  has_many :comentarios, dependent: :nullify

  validates :nome, presence: true
  
  enum :papel, { usuario: 'usuario', moderador: 'moderador', admin: 'admin' }

  def admin?
    papel == 'admin'
  end

  def moderador?
    papel == 'moderador'
  end
end
