LivePreviewViewManager = require './live-preview-view-manager'

module.exports =
class LivePreview
  @configDefaults:
    liveUpdate: true

  @activate: =>
    @livePreviewViewManager = new LivePreviewViewManager('live-preview:')

    atom.workspaceView.command 'live-preview:toggle', =>
      @livePreviewViewManager.togglePreview()
