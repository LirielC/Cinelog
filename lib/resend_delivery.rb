# Adapter para usar Resend com ActionMailer
class ResendDelivery
  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    return unless ENV['RESEND_API_KEY'].present?

    params = {
      from: mail.from.first,
      to: mail.to,
      subject: mail.subject,
      html: mail.html_part&.body&.to_s || mail.body.to_s
    }

    Resend::Emails.send(params)
  end
end
