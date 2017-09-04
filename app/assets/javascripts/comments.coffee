ready = ->
  $('.add-comment-link').click (e) ->
    e.preventDefault();
    $('.new-comment').show();

  $(".new-comment").bind 'ajax:success', (e, data, status, xhr) ->
    data = $.parseJSON(xhr.responseText)
    $('.comments table tbody').append(data.body_html)
    $(this).hide();

  $(".edit-comment").bind 'ajax:success', (e, data, status, xhr) ->
    data = $.parseJSON(xhr.responseText)
    $('tr#show'+data.id).replaceWith(data.body_html)
    $('tr#show'+data.id).show();
    $('tr#edit'+data.id).hide();

  $('.cancel-comment-link').click (e) ->
    e.preventDefault();
    comment_id = $(this).data('commentId')
    if (comment_id?)
      $(comment_id).hide();
    else
      $('.new-comment').hide();

  $('.edit-comment-link').click (e) ->
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
      if (data.action=="create")
        $('.comments table tbody').append(data.body_html)
      else # update
        $('tr#show'+data.id).replaceWith(data.body_html)
  });

$(document).ready(ready)
$(document).on('turbolinks', ready)
