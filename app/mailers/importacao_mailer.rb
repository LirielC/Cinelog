class ImportacaoMailer < ApplicationMailer
  default from: 'noreply@cinelog.com'

  # Envia e-mail quando a importação é concluída com sucesso
  def importacao_concluida(importacao_id)
    @importacao = Importacao.find(importacao_id)
    @usuario = @importacao.usuario
    
    mail(
      to: @usuario.email,
      subject: '✅ Importação de Filmes Concluída - Cinelog'
    )
  end

  # Envia e-mail quando a importação falha
  def importacao_falhou(importacao_id)
    @importacao = Importacao.find(importacao_id)
    @usuario = @importacao.usuario
    
    mail(
      to: @usuario.email,
      subject: '❌ Erro na Importação de Filmes - Cinelog'
    )
  end
end
