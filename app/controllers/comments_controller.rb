class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_comment, only: [:update]

  authorize_resource
  respond_to :json

  def create
    @comment = current_user.comments.create(comment_params)
    if @comment.errors.empty?
      flash_message :success, t("flash.comments.create.notice")
      render "comments/create.json"
    else
      errors_to_flash @comment
      render "comments/create.json", status: 422
    end
  end

  def update
    @comment.update(comment_params)
    if @comment.errors.empty?
      flash_message :success, t("flash.comments.update.notice")
      render "comments/create.json"
    else
      errors_to_flash @comment
      render "comments/create.json", status: 422
    end
  end

  private

  def load_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
