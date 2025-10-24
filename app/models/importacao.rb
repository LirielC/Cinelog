class Importacao < ApplicationRecord
  belongs_to :usuario

  # Constantes de status
  STATUS_PENDENTE = 'pendente'
  STATUS_PROCESSANDO = 'processando'
  STATUS_CONCLUIDO = 'concluido'
  STATUS_FALHA = 'falha'

  # Validações
  validates :arquivo, presence: true
  validates :status, inclusion: { in: [STATUS_PENDENTE, STATUS_PROCESSANDO, STATUS_CONCLUIDO, STATUS_FALHA] }

  # Scopes
  scope :pendentes, -> { where(status: STATUS_PENDENTE) }
  scope :processando, -> { where(status: STATUS_PROCESSANDO) }
  scope :concluidas, -> { where(status: STATUS_CONCLUIDO) }
  scope :com_falha, -> { where(status: STATUS_FALHA) }

  # Métodos auxiliares
  def pendente?
    status == STATUS_PENDENTE
  end

  def processando?
    status == STATUS_PROCESSANDO
  end

  def concluido?
    status == STATUS_CONCLUIDO
  end

  def falhou?
    status == STATUS_FALHA
  end

  def percentual_sucesso
    return 0 if total_linhas.to_i.zero?
    ((criados.to_f / total_linhas) * 100).round(2)
  end
end
