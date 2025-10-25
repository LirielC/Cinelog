# Adapter para usar SendGrid com ActionMailer via API HTTP
class SendgridDelivery
  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    return unless ENV['SENDGRID_API_KEY'].present?

    require 'sendgrid-ruby'
    
    # Criar objetos SendGrid
    from = SendGrid::Email.new(email: mail.from.first)
    to = SendGrid::Email.new(email: mail.to.first)
    subject = mail.subject
    content = SendGrid::Content.new(
      type: 'text/html', 
      value: mail.html_part&.body&.to_s || mail.body.to_s
    )
    
    mail_obj = SendGrid::Mail.new(from, subject, to, content)
    
    # Enviar via API
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail_obj.to_json)
    
    # Log detalhado do resultado
    if response.status_code.to_i >= 200 && response.status_code.to_i < 300
      Rails.logger.info "✅ Email enviado com sucesso via SendGrid: #{response.status_code}"
    else
      Rails.logger.error "❌ Erro ao enviar email via SendGrid:"
      Rails.logger.error "   Status: #{response.status_code}"
      Rails.logger.error "   Body: #{response.body}"
      Rails.logger.error "   Headers: #{response.headers}"
    end
    
    response
  rescue => e
    Rails.logger.error "❌ Exceção ao enviar email: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    raise
  end
end
