$ ->
  $('.add-comment-link').click (e) ->
    e.preventDefault();
    $('.new-comment').show();

  $(".new-comment").bind 'ajax:success', (e, data, status, xhr) ->
    data = $.parseJSON(xhr.responseText)
    $('.comments table tbody').append(data.body_html)
    $(this).hide();

  $('.cancel-comment-link').click (e) ->
    e.preventDefault();
    $('.new-comment').hide();