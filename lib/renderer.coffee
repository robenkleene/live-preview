exports.toHtml = (text='', callback) ->
  html = "<pre><code>#{text}</code></pre>"
  callback(null, html)
