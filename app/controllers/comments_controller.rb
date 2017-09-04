class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_comment, only: [:update]
  after_action :publish_comment, only: %i[create update]

  authorize_resource
  respond_to :json

  def create
    @comment = current_user.comments.create(comment_params)
    if @comment.errors.empty?
      @action = :create
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
      @action = :update
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

  def publish_comment
    return if @comment.errors.any?
    ActionCable.server.broadcast(
        "comments",
        renderer.render(
            "comments/create.json",
            locals: { comment: @comment, action: @action }
        )
    )
  end

end
