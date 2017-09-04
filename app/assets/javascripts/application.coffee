# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require turbolinks
#= require_tree .

$(document).bind 'ajax:success', (e, data, status, xhr) ->
  show_flash_messages(xhr)
.bind 'ajax:error', (e, xhr, status, error) ->
  show_flash_messages(xhr)

root = exports ? this

root.show_flash_messages = (xhr) ->
  try
    datas = $.parseJSON(xhr.responseText)
    if datas.messages?
      $('.flash').append(datas.messages);
