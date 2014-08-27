LivePreviewView = require '../live-preview-view'
module.exports =
class CodePreviewView extends LivePreviewView

  getLiveUpdateConfig: ->
    atom.config.get 'code-preview.liveUpdate'

  getTitle: ->
    if @editor?
      "#{@editor.getTitle()} Code Preview"
    else
      "Code Preview"

  resolveRenderer: =>
    @renderer = require './code-renderer-wrapper'
