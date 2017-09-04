class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  #skip_authorization_check

  def facebook
    provider_callback(:facebook)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.temp_email?
        finish_signup_path(resource)
      else
        super
      end
  end

  def failure
    redirect_to root_path
  end

  private

  def provider_callback(provider)
    @user = User.find_for_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "#{provider.capitalize}") if is_navigational_format?
    else
      session["devise.#{provider}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end