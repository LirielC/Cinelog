# Configuração do SendGrid para envio de emails via API
# A API key deve ser configurada como variável de ambiente SENDGRID_API_KEY
if Rails.env.production? && ENV['SENDGRID_API_KEY'].blank?
  Rails.logger.warn "⚠️  SENDGRID_API_KEY não configurada. Emails não serão enviados."
end
