require "application_responder"

class ApplicationController < ActionController::Base
  include ApplicationHelper

  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :exception

  check_authorization :unless => :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_signup_complete, only: [:new, :create, :update, :destroy]

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :email, :password,
                                                              :password_confirmation, :current_password])
  end

  private

  def ensure_signup_complete
    # Убеждаемся, что цикл не бесконечный
    return if action_name == 'finish_signup' || (controller_name=="sessions" && action_name=="destroy")

    # Редирект на адрес 'finish_signup' если пользователь
    # не подтвердил свою почту
    if current_user&.temp_email?
      redirect_to finish_signup_path(current_user)
    end
  end

end
