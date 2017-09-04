if @comment.errors.empty?
  json.(@comment, :id, :body)
  json.body_html ApplicationController.render(
      partial: "comments/comment",
      locals: { comment: @comment }
  )
  flash_message :success, t("flash.comments.create.notice")
  json.user_id current_user.id
end
json.messages bootstrap_flash
