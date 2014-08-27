UriHelper = require './uri-helper'

module.exports =
class LivePreviewViewManager
  @previewView = null

  constructor: (@protocol, @factory) ->
    atom.workspace.registerOpener (uri) =>
      editorId = UriHelper.editorIdForUri(@protocol, uri)
      if editorId?
        new @createPreviewView(uri)

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
        if @isPreviewView(previewView)
          previewView.render()
          previousActivePane.activate()

  removePreviewIfActive: ->
    if @isPreviewView(atom.workspace.activePaneItem)
      atom.workspace.destroyActivePaneItem()
      return true
    return false

  createPreviewView: (uri) =>
    @resolvePreviewView() unless @PreviewView?
    new @PreviewView(uri)

  isPreviewView: (object) ->
    @resolvePreviewView() unless @PreviewView?
    object instanceof @PreviewView

  resolvePreviewView: =>
    @PreviewView ?= @factory.getPreviewView()
