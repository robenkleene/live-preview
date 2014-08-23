CodeRenderer = require './code-renderer'
{$$$} = require 'atom'

exports.showError = (errorMessage, view) ->
  view.html $$$ ->
    @h2 'Preview Failed'
    @h3 errorMessage if errorMessage?

exports.showLoading = (view) ->
  view.html $$$ ->
    @div class: 'live-preview-spinner', 'Loading\u2026'

exports.render = (text, view) ->
  @showLoading(view)
  CodeRenderer.toHtml text, (error, result) ->
    if error
      errorMessage = error?.message
      @showError(errorMessage, view)
    else
      view.html(result)
