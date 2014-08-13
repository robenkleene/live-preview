cheerio = require 'cheerio'

exports.toHtml = (text='', callback) ->
  # process.nextTick is attempt to get promise working, doesn't work yet
  process.nextTick ->
    html = "<pre><code>#{text}</code></pre>"
    html = sanitize(html)
    callback(null, html)

sanitize = (html) ->
  o = cheerio.load("<div>#{html}</div>")
  o('script').remove()
  attributesToRemove = [
    'onabort'
    'onblur'
    'onchange'
    'onclick'
    'ondbclick'
    'onerror'
    'onfocus'
    'onkeydown'
    'onkeypress'
    'onkeyup'
    'onload'
    'onmousedown'
    'onmousemove'
    'onmouseover'
    'onmouseout'
    'onmouseup'
    'onreset'
    'onresize'
    'onscroll'
    'onselect'
    'onsubmit'
    'onunload'
  ]
  o('*').removeAttr(attribute) for attribute in attributesToRemove
  o.html()
