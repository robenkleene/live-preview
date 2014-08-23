previewView = null
UriHelper = require './uri-helper'

createPreviewView = (uri) ->
  previewView ?= require './live-preview-view'
  new previewView(uri)

isPreviewView = (object) ->
  previewView ?= require './live-preview-view'
  object instanceof previewView

module.exports =
class LivePreviewViewManager
  constructor: (@protocol) ->
    atom.workspace.registerOpener (uri) =>
      editorId = UriHelper.editorIdForUri(@protocol, uri)
      if editorId
        new createPreviewView(uri)


  togglePreviewForEditorId: (editorId) =>
    uri = UriHelper.uriForEditorId(@protocol, editorId)
    @addPreviewForUri(uri) unless @removePreviewForUri(uri)

  removePreviewIfActive: ->
    if isPreviewView(atom.workspace.activePaneItem)
      atom.workspace.destroyActivePaneItem()
      return

  removePreviewForUri: (uri) ->
    previewPane = atom.workspace.paneForUri(uri)

    if previewPane?
      previewPane.destroyItem(previewPane.itemForUri(uri))
      return true
    else
      return false

  addPreviewForUri: (uri) ->
    previousActivePane = atom.workspace.getActivePane()

    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (previewView) ->
      if isPreviewView(previewView)
        previewView.render()
        previousActivePane.activate()
