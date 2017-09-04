@comment = @comment || local_assigns[:comment]
if @comment.errors.empty?
  json.(@comment, :id, :body)
  json.body_html renderer.render(
      partial: "comments/comment",
      locals: { comment: @comment, action: local_assigns[:action] }
  )
  json.user_id current_user.id
  json.action local_assigns[:action]
end
json.messages bootstrap_flash
