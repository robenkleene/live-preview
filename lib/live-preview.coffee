url = require 'url'
previewView = null

createPreviewView = (state) ->
  previewView ?= require './live-preview-view'
  new previewView(state)

isPreviewView = (object) ->
  previewView ?= require './live-preview-view'
  object instanceof previewView

module.exports =
class LivePreview
  @configDefaults:
    liveUpdate: true

  @activate: ->
    atom.workspaceView.command "#{@getPackageName()}:toggle", =>
      @toggle()

    atom.workspace.registerOpener (uriToOpen) =>
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        console.log error
        return

      return unless protocol is @getProtocol()
      return unless host is 'editor'

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      new createPreviewView(pathname.substring(1))


  @toggle: ->
    if isPreviewView(atom.workspace.activePaneItem)
      atom.workspace.destroyActivePaneItem()
      return

    editor = atom.workspace.getActiveEditor()
    return unless editor?

    # grammars = atom.config.get('markdown-preview.grammars') ? []
    # return unless editor.getGrammar().scopeName in grammars

    @addPreviewForEditor(editor) unless @removePreviewForEditor(editor)

  @uriForEditor: (editor) =>
    "#{@getProtocol()}//editor/#{editor.id}"

  @removePreviewForEditor: (editor) ->
    uri = @uriForEditor(editor)
    previewPane = atom.workspace.paneForUri(uri)
    if previewPane?
      previewPane.destroyItem(previewPane.itemForUri(uri))
      true
    else
      false

  @addPreviewForEditor: (editor) ->
    uri = @uriForEditor(editor)
    previousActivePane = atom.workspace.getActivePane()

    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (previewView) ->
      if isPreviewView(previewView)
        previewView.render()
        previousActivePane.activate()

  @getPackageName: ->
    'live-preview'

  @getProtocol: ->
    'live-preview:'
