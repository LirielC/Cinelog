require 'csv'

class ImportacaoJob < ApplicationJob
  queue_as :importacoes

  # Tamanho máximo do arquivo: 5MB
  TAMANHO_MAXIMO = 5.megabytes
  
  # Colunas esperadas no CSV
  COLUNAS_ESPERADAS = %w[titulo sinopse ano_lancamento duracao_minutos diretor categorias].freeze

  def perform(importacao_id)
    importacao = Importacao.find(importacao_id)
    
    # Atualizar status para processando
    importacao.update!(status: Importacao::STATUS_PROCESSANDO)

    # Validar existência do arquivo
    unless File.exist?(importacao.arquivo)
      registrar_erro(importacao, "Arquivo não encontrado: #{importacao.arquivo}")
      return
    end

    # Validar tamanho do arquivo
    tamanho_arquivo = File.size(importacao.arquivo)
    if tamanho_arquivo > TAMANHO_MAXIMO
      registrar_erro(importacao, "Arquivo muito grande (#{tamanho_arquivo} bytes). Máximo: #{TAMANHO_MAXIMO} bytes")
      return
    end

    # Processar CSV
    processar_csv(importacao)

  rescue StandardError => e
    Rails.logger.error("Erro ao processar importação #{importacao_id}: #{e.message}")
    registrar_erro(importacao, "Erro inesperado: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
  ensure
    # Limpar arquivo temporário
    File.delete(importacao.arquivo) if File.exist?(importacao.arquivo)
  end

  private

  def processar_csv(importacao)
    erros_lista = []
    criados = 0
    linha_numero = 0

    CSV.foreach(importacao.arquivo, headers: true, encoding: 'UTF-8') do |linha|
      linha_numero += 1

      # Pular linha se cabeçalho inválido (primeira iteração)
      if linha_numero == 1 && !validar_cabecalhos(linha.headers)
        registrar_erro(
          importacao, 
          "Cabeçalhos inválidos. Esperado: #{COLUNAS_ESPERADAS.join(', ')}. Encontrado: #{linha.headers.join(', ')}"
        )
        return
      end

      # Criar filme
      resultado = criar_filme_from_linha(linha, importacao.usuario)
      
      if resultado[:sucesso]
        criados += 1
      else
        erros_lista << "Linha #{linha_numero}: #{resultado[:erro]}"
      end
    end

    # Calcular total e falhas
    total_linhas = linha_numero
    falhas = total_linhas - criados

    # Atualizar importacao
    importacao.update!(
      status: Importacao::STATUS_CONCLUIDO,
      total_linhas: total_linhas,
      criados: criados,
      falhas: falhas,
      erros: erros_lista.join("\n")
    )

    Rails.logger.info("Importação #{importacao.id} concluída: #{criados}/#{total_linhas} filmes criados")

    # Enviar e-mail de notificação
    ImportacaoMailer.importacao_concluida(importacao.id).deliver_later

  rescue CSV::MalformedCSVError => e
    registrar_erro(importacao, "Arquivo CSV malformado: #{e.message}")
  end

  def validar_cabecalhos(cabecalhos_csv)
    return false if cabecalhos_csv.nil?
    COLUNAS_ESPERADAS.all? { |col| cabecalhos_csv.include?(col) }
  end

  def criar_filme_from_linha(linha, usuario)
    # Extrair dados da linha
    titulo = linha['titulo']&.strip
    sinopse = linha['sinopse']&.strip
    ano = linha['ano_lancamento']&.strip
    duracao = linha['duracao_minutos']&.strip
    diretor = linha['diretor']&.strip
    categorias_str = linha['categorias']&.strip

    # Validar campos obrigatórios
    if titulo.blank?
      return { sucesso: false, erro: 'Título não pode estar vazio' }
    end

    # Criar filme
    filme = Filme.new(
      titulo: titulo,
      sinopse: sinopse,
      ano_lancamento: ano.present? ? ano.to_i : nil,
      duracao_minutos: duracao.present? ? duracao.to_i : nil,
      diretor: diretor,
      usuario: usuario
    )

    # Associar categorias se fornecidas
    if categorias_str.present?
      nomes_categorias = categorias_str.split(',').map(&:strip)
      categorias = nomes_categorias.map do |nome|
        Categoria.find_or_create_by!(nome: nome)
      end
      filme.categorias = categorias
    end

    # Salvar filme
    if filme.save
      { sucesso: true, filme: filme }
    else
      { sucesso: false, erro: filme.errors.full_messages.join(', ') }
    end

  rescue StandardError => e
    { sucesso: false, erro: "Erro ao criar filme: #{e.message}" }
  end

  def registrar_erro(importacao, mensagem_erro)
    importacao.update!(
      status: Importacao::STATUS_FALHA,
      erros: mensagem_erro
    )
    Rails.logger.error("Importação #{importacao.id} falhou: #{mensagem_erro}")
    
    # Enviar e-mail de notificação de falha
    ImportacaoMailer.importacao_falhou(importacao.id).deliver_later
  end
end
