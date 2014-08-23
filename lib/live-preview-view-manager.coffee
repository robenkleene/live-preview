url = require 'url'
previewView = null

createPreviewView = (state) ->
  previewView ?= require './live-preview-view'
  new previewView(state)

isPreviewView = (object) ->
  previewView ?= require './live-preview-view'
  object instanceof previewView


module.exports =
class LivePreviewViewManager
  constructor: (@protocol) ->
    atom.workspace.registerOpener (uri) =>
      editorId = @editorIdForUri(uri)
      if editorId
        new createPreviewView(editorId)

  togglePreviewForEditorId: (editorId) =>
    @addPreviewForEditorId(editorId) unless @removePreviewForEditorId(editorId)

  editorIdForUri: (uri) =>
    try
      {protocol, host, pathname} = url.parse(uri)
    catch error
      console.error error
      return
    return unless protocol is @protocol
    return unless host is 'editor'

    try
      pathname = decodeURI(pathname) if pathname
    catch error
      console.error error
      return

    return pathname.substring(1)


  uriForEditorId: (editorId) =>
    "#{@protocol}//editor/#{editorId}"

  removePreviewIfActive: ->
    if isPreviewView(atom.workspace.activePaneItem)
      atom.workspace.destroyActivePaneItem()
      return

  removePreviewForEditorId: (editorId) =>
    uri = @uriForEditorId(editorId)
    previewPane = atom.workspace.paneForUri(uri)

    if previewPane?
      previewPane.destroyItem(previewPane.itemForUri(uri))
      return true
    else
      return false

  addPreviewForEditorId: (editorId) =>
    uri = @uriForEditorId(editorId)
    previousActivePane = atom.workspace.getActivePane()

    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (previewView) ->
      if isPreviewView(previewView)
        previewView.render()
        previousActivePane.activate()
