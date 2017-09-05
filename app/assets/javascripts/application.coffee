# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
# ... your other scripts here ... [
#= require twitter/bootstrap
# ]... your other scripts here ...
#= require turbolinks
#= require_tree .

ready = ->
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

$(document).ready(ready) # "вешаем" функцию ready на событие document.ready
$(document).on('turbolinks', ready)  # "вешаем" функцию ready на событие turbolinks:load
