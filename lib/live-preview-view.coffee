{$$$, ScrollView} = require 'atom'
UriHelper = require './uri-helper'

module.exports =
class LivePreviewView extends ScrollView
  atom.deserializers.add(this)

  @content: ->
    @div class: 'live-preview native-key-bindings', tabindex: -1

  constructor: (@uri) ->
    super
    @resolveRenderer()
    @resolveEditor()

  @deserialize: ({uri}) ->
    new LivePreviewView(uri)

  serialize: ->
    {@uri, deserializer: @constructor.name}

  destroy: ->
    @unsubscribe()

  resolveEditor: ->
    resolve = =>
      @editor = @editorForUri(@uri)

      if @editor?
        @trigger 'title-changed' if @editor?
        @handleEvents()
      else
        # The editor this preview was created for has been closed so close
        # this preview since a preview cannot be rendered without an editor
        @parents('.pane').view()?.destroyItem(this)

    if atom.workspace?
      resolve()
    else
      @subscribe atom.packages.once 'activated', =>
        resolve()
        @render()

  editorForUri: (uri) ->
    protocol = UriHelper.protocolForUri(@uri)
    editorId = UriHelper.editorIdForUri(protocol, @uri)

    for editor in atom.workspace.getEditors()
      return editor if editor.id?.toString() is editorId.toString()
    return null

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

    changeHandler = =>
      @render()
      pane = atom.workspace.paneForUri(@uri)
      if pane? and pane isnt atom.workspace.getActivePane()
        pane.activateItem(this)

    if @editor?
      @subscribe @editor.getBuffer(), 'contents-modified', ->
        changeHandler() if atom.config.get 'live-preview.liveUpdate'
      @subscribe @editor, 'path-changed', => @trigger 'title-changed'
      @subscribe @editor.getBuffer(), 'reloaded saved', ->
        changeHandler() unless atom.config.get 'live-preview.liveUpdate'

  render: ->
    @showLoading()
    if @editor?
      @renderText(@editor.getText())

  renderText: (text) ->
    @renderer.toHtml text, (error, html) =>
      if error
        @showError(error)
      else
        @html(html)

  showError: (result) ->
    failureMessage = result?.message
    @html $$$ ->
      @h2 'Previewing Failed'
      @h3 failureMessage if failureMessage?

  showLoading: ->
    @html $$$ ->
      @div class: 'live-preview-spinner', 'Loading\u2026'

  getTitle: ->
    if @editor?
      "#{@editor.getTitle()} Preview"
    else
      "Preview"

  getIconName: ->
    "markdown" # TODO Replace with langauges icon

  getPath: ->
    @editor.getPath()

  getUri: ->
    @uri

  resolveRenderer: =>
    @renderer = require './renderer'
