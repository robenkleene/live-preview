previewView = null

LivePreviewViewManager = require './live-preview-view-manager'

isPreviewView = (object) ->
  previewView ?= require './live-preview-view'
  object instanceof previewView

module.exports =
class LivePreview
  @configDefaults:
    liveUpdate: true

  @activate: =>
    @livePreviewViewManager = new LivePreviewViewManager('live-preview:')

    atom.workspaceView.command 'live-preview:toggle', =>
      if isPreviewView(atom.workspace.activePaneItem)
        atom.workspace.destroyActivePaneItem()
        return

      editor = atom.workspace.getActiveEditor()
      return unless editor?

      # grammars = atom.config.get('markdown-preview.grammars') ? []
      # return unless editor.getGrammar().scopeName in grammars

      @livePreviewViewManager.togglePreviewForEditorId(editor.id)
