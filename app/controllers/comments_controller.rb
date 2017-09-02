class CommentsController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_with(@comments = Comment.all)
  end
end
