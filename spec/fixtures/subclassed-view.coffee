LivePreviewView = require '../../lib/live-preview-view'

module.exports =
class SubclassedView extends LivePreviewView

  # getTitle: ->
  #   if @editor?
  #     "#{@editor.getTitle()} Preview"
  #   else
  #     "Preview"
  #
  # getIconName: ->
  #   "markdown" # TODO Replace with language icon
  #
  # resolveRenderer: =>
  #   @renderer = require './renderer'
