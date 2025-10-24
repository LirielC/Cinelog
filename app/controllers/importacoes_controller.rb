class ImportacoesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :set_importacao, only: [:show]

  # Tamanho máximo: 5MB
  TAMANHO_MAXIMO = 5.megabytes

  def new
    @importacao = Importacao.new
  end

  def create
    # Validar presença do arquivo
    unless params[:importacao] && params[:importacao][:arquivo]
      redirect_to new_importacao_path, alert: 'Por favor, selecione um arquivo CSV.' and return
    end

    arquivo_upload = params[:importacao][:arquivo]

    # Validar tipo do arquivo
    unless arquivo_upload.content_type.in?(['text/csv', 'application/vnd.ms-excel', 'text/plain'])
      redirect_to new_importacao_path, alert: 'Tipo de arquivo inválido. Apenas arquivos CSV são permitidos.' and return
    end

    # Validar tamanho
    if arquivo_upload.size > TAMANHO_MAXIMO
      redirect_to new_importacao_path, 
                  alert: "Arquivo muito grande (#{(arquivo_upload.size / 1.megabyte).round(2)}MB). Máximo: 5MB." and return
    end

    # Salvar arquivo temporariamente
    caminho_temporario = Rails.root.join('tmp', "importacao_#{Time.current.to_i}_#{arquivo_upload.original_filename}")
    File.open(caminho_temporario, 'wb') do |file|
      file.write(arquivo_upload.read)
    end

    # Criar registro de importação
    @importacao = Importacao.new(
      usuario: current_usuario,
      arquivo: caminho_temporario.to_s,
      status: Importacao::STATUS_PENDENTE
    )

    if @importacao.save
      # Enfileirar job para processar
      ImportacaoJob.perform_later(@importacao.id)
      
      redirect_to importacao_path(@importacao), 
                  notice: 'Arquivo enviado com sucesso! A importação está sendo processada.'
    else
      File.delete(caminho_temporario) if File.exist?(caminho_temporario)
      redirect_to new_importacao_path, alert: "Erro ao criar importação: #{@importacao.errors.full_messages.join(', ')}"
    end

  rescue StandardError => e
    Rails.logger.error("Erro no upload de importação: #{e.message}")
    File.delete(caminho_temporario) if caminho_temporario && File.exist?(caminho_temporario)
    redirect_to new_importacao_path, alert: "Erro ao processar arquivo: #{e.message}"
  end

  def show
    # A view mostrará o status da importação
  end

  private

  def set_importacao
    @importacao = Importacao.find(params[:id])
    
    # Verificar se o usuário é dono da importação ou admin
    unless @importacao.usuario == current_usuario || current_usuario.admin?
      redirect_to root_path, alert: 'Você não tem permissão para ver esta importação.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Importação não encontrada.'
  end
end
