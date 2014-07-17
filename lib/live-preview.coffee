url = require 'url'
previewView = null

createPreviewView = (state) ->
  previewView ?= require './live-preview-view'
  new previewView(state)

isPreviewView = (object) ->
  previewView ?= require './live-preview-view'
  object instanceof previewView

deserializer =
  name: 'previewView'
  deserialize: (state) ->
    createPreviewView(state) if state.constructor is Object
atom.deserializers.add(deserializer)


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

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      if host is 'editor'
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
        previewView.renderPreview()
        previousActivePane.activate()

  @getPackageName: ->
    'live-preview'

  @getProtocol: ->
    'live-preview:'
