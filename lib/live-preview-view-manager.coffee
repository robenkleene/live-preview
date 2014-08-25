UriHelper = require './uri-helper'

module.exports =
class LivePreviewViewManager
  @previewView = null

  constructor: (@protocol, @factory) ->
    atom.workspace.registerOpener (uri) =>
      editorId = UriHelper.editorIdForUri(@protocol, uri)
      if editorId?
        new @factory.createPreviewView(uri)

  togglePreview: =>
    if @removePreviewIfActive()
      return

    editor = atom.workspace.getActiveEditor()
    return unless editor?

    @togglePreviewForEditorId(editor.id)

  togglePreviewForEditorId: (editorId) =>
    uri = UriHelper.uriForEditorId(@protocol, editorId)
    previewPane = atom.workspace.paneForUri(uri)
    if previewPane?
      previewPane.destroyItem(previewPane.itemForUri(uri))
    else
      previousActivePane = atom.workspace.getActivePane()
      atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (previewView) =>
        if @factory.isPreviewView(previewView)
          previewView.render()
          previousActivePane.activate()

  removePreviewIfActive: ->
    if @factory.isPreviewView(atom.workspace.activePaneItem)
      atom.workspace.destroyActivePaneItem()
      return true
    return false
