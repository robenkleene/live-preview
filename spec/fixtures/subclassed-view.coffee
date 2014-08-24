LivePreviewView = require '../../lib/live-preview-view'

module.exports =
class SubclassedView extends LivePreviewView

  getTitle: ->
    if @editor?
      "#{@editor.getTitle()} Subclassed Preview"
    else
      "Subclassed Preview"

  getIconName: ->
    "coffee"

  resolveRenderer: =>
    @renderer = require './test-renderer'
