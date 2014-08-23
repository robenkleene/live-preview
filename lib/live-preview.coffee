# url = require 'url'
previewView = null

LivePreviewViewManager = require './live-preview-view-manager'

# createPreviewView = (state) ->
#   previewView ?= require './live-preview-view'
#   new previewView(state)

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



  #   atom.workspace.registerOpener (uri) =>
  #     editorId = @editorIdForUri(uri)
  #     if editorId
  #       new createPreviewView(editorId)
  #
  # @toggle: ->
  #   if isPreviewView(atom.workspace.activePaneItem)
  #     atom.workspace.destroyActivePaneItem()
  #     return
  #
  #   editor = atom.workspace.getActiveEditor()
  #   return unless editor?
  #
  #   # grammars = atom.config.get('markdown-preview.grammars') ? []
  #   # return unless editor.getGrammar().scopeName in grammars
  #
  #   @addPreviewForEditorId(editor.id) unless @removePreviewForEditorId(editor.id)
  #
  # @editorIdForUri: (uri) =>
  #   try
  #     {protocol, host, pathname} = url.parse(uri)
  #   catch error
  #     console.error error
  #     return
  #   return unless protocol is @getProtocol()
  #   return unless host is 'editor'
  #
  #   try
  #     pathname = decodeURI(pathname) if pathname
  #   catch error
  #     console.error error
  #     return
  #
  #   return pathname.substring(1)
  #
  # @uriForEditorId: (editorId) =>
  #   "#{@getProtocol()}//editor/#{editorId}"
  #
  # @removePreviewForEditorId: (editorId) ->
  #   uri = @uriForEditorId(editorId)
  #   previewPane = atom.workspace.paneForUri(uri)
  #   if previewPane?
  #     previewPane.destroyItem(previewPane.itemForUri(uri))
  #     true
  #   else
  #     false
  #
  # @addPreviewForEditorId: (editorId) ->
  #   uri = @uriForEditorId(editorId)
  #   previousActivePane = atom.workspace.getActivePane()
  #
  #   atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (previewView) ->
  #     if isPreviewView(previewView)
  #       previewView.render()
  #       previousActivePane.activate()

  # @getPackageName: ->
  #   'live-preview'
  #
  # @getProtocol: ->
  #   'live-preview:'
