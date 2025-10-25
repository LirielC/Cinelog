# Adapter para usar SendGrid com ActionMailer via API HTTP
class SendgridDelivery
  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    return unless ENV['SENDGRID_API_KEY'].present?

    require 'sendgrid-ruby'
    include SendGrid

    from = Email.new(email: mail.from.first)
    to = Email.new(email: mail.to.first)
    subject = mail.subject
    content = Content.new(type: 'text/html', value: mail.html_part&.body&.to_s || mail.body.to_s)
    
    mail_obj = Mail.new(from, subject, to, content)
    
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._('send').post(request_body: mail_obj.to_json)
  end
end
