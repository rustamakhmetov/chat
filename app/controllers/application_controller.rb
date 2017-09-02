require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :email, :password, :password_confirmation,
                                                              :current_password])
  end
end
