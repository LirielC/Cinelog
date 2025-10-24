class Usuarios::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  # Permite o parâmetro :nome ao criar conta
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome])
  end

  # Permite o parâmetro :nome ao atualizar conta
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:nome])
  end
end
