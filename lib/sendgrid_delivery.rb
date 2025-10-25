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
    
    # Log do resultado
    Rails.logger.info "📧 Email enviado via SendGrid: #{response.status_code}"
    
    response
  end
end
