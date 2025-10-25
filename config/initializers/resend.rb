# Configuração do Resend para envio de emails via API
if ENV['RESEND_API_KEY'].present?
  Resend.api_key = ENV['RESEND_API_KEY']
end
