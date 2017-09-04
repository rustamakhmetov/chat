class DashboardController < ApplicationController
  skip_authorization_check

  def index
    redirect_to new_user_session_path unless user_signed_in?
    @comments = Comment.all
  end
end