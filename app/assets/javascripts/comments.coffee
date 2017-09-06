ready = ->
  $(document).on 'click', '.add-comment-link', (e) ->
    e.preventDefault();
    $('#comment_body').val("")
    $('.new-comment').show();

  $(".new-comment").bind 'ajax:success', (e, data, status, xhr) ->
    data = $.parseJSON(xhr.responseText)
    unless $('#show'+data.id).length
      $('.comments table tbody').append(data.body_html)
      $(this).hide();
      $(".edit-comment").bind 'ajax:success', (e, data, status, xhr) =>
        onEditBind e, data, status, xhr

  onEditBind = (e, data, status, xhr) ->
    data = $.parseJSON(xhr.responseText)
    $('tr#show'+data.id).replaceWith(data.body_html)
    $('tr#show'+data.id).show();
    $('tr#edit'+data.id).hide();

  $(".edit-comment").bind 'ajax:success', (e, data, status, xhr) =>
    onEditBind e, data, status, xhr

  $(document).on 'click', '.cancel-comment-link', (e) ->
    e.preventDefault();
    comment_id = $(this).data('commentId')
    if (comment_id?)
      $("#edit"+comment_id).hide();
      $("#show"+comment_id).show();
    else
      $('.new-comment').hide();

  $(document).on 'click', '.edit-comment-link', (e) ->
    e.preventDefault();
    comment_id = $(this).data('commentId')
    $('#edit'+comment_id).show();
    $('#show'+comment_id).hide();


$(document).ready ->
  App.cable.subscriptions.create({
    channel: 'CommentsChannel'
  }, {
    received: (data) ->
      data = $.parseJSON(data)
      user_data = $('a#logout').data()
      if user_data and data.user_id!=user_data.userId
        if (data.action=="create")
          $('.comments table tbody').append(data.body_html)
        else # update
          $('tr#show'+data.id).replaceWith(data.body_html)
  });

$(document).ready(ready)
$(document).on('turbolinks:load', ready)