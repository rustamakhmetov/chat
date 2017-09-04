class CommentsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def create
    @comment = current_user.comments.create(comment_params)
    if @comment.errors.empty?
      render "comments/create.json"
    else
      errors_to_flash @comment
      render "comments/create.json", status: 422
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
