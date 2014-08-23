LivePreviewViewManager = require './live-preview-view-manager'

module.exports =
class LivePreview
  @configDefaults:
    liveUpdate: true

  @activate: =>
    @livePreviewViewManager = new LivePreviewViewManager('live-preview:')

    atom.workspaceView.command 'live-preview:toggle', =>

      @livePreviewViewManager.removePreviewIfActive()

      editor = atom.workspace.getActiveEditor()
      return unless editor?

      # grammars = atom.config.get('markdown-preview.grammars') ? []
      # return unless editor.getGrammar().scopeName in grammars

      @livePreviewViewManager.togglePreviewForEditorId(editor.id)
