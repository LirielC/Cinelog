class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :usuario_nao_autorizado

  # Configurar Pundit para usar current_usuario ao invés de current_user
  def pundit_user
    current_usuario
  end

  private

  def usuario_nao_autorizado
    flash[:alert] = 'Você não está autorizado a executar esta ação.'
    redirect_to(request.referrer || root_path)
  end
end
