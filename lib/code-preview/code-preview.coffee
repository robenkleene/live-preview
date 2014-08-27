LivePreviewViewManager = require '../live-preview-view-manager'
CodePreviewViewFactory = require './code-preview-view-factory'

deserializer =
  name: 'CodePreviewView'
  deserialize: (state) ->
    if state.constructor is Object
      CodePreviewView = CodePreviewViewFactory.getPreviewView()
      uri = state.uri
      new CodePreviewView(uri)
atom.deserializers.add(deserializer)

module.exports =
class CodePreview
  @configDefaults:
    liveUpdate: true

  @activate: =>
    @livePreviewViewManager = new LivePreviewViewManager('code-preview:', CodePreviewViewFactory)

    atom.workspaceView.command 'code-preview:toggle', =>
      @livePreviewViewManager.togglePreview()
