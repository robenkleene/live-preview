module.exports =
class LivePreviewViewFactory
  @createPreviewView: (uri) =>
    @resolvePreviewView() unless @PreviewView?
    new @PreviewView(uri)

  @isPreviewView: (object) ->
    @resolvePreviewView() unless @PreviewView?
    object instanceof @PreviewView

  @resolvePreviewView: =>
    @PreviewView ?= require './live-preview-view'
