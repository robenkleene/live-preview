LivePreviewViewManager = require './live-preview-view-manager'

class LivePreviewViewFactory
  @createPreviewView: (uri) =>
    @PreviewView ?= require './live-preview-view'
    new @PreviewView(uri)

  @isPreviewView: (object) ->
    @PreviewView ?= require './live-preview-view'
    object instanceof @PreviewView

deserializer =
  name: 'LivePreviewView'
  deserialize: (state) ->
    LivePreviewViewFactory.createPreviewView(state.uri) if state.constructor is Object
atom.deserializers.add(deserializer)

module.exports =
class LivePreview
  @configDefaults:
    liveUpdate: true

  @activate: =>
    @livePreviewViewManager = new LivePreviewViewManager('live-preview:', LivePreviewViewFactory)

    atom.workspaceView.command 'live-preview:toggle', =>
      @livePreviewViewManager.togglePreview()
