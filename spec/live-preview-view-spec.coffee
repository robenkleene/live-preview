{WorkspaceView} = require 'atom'
LivePreviewView = require '../lib/live-preview-view'
UriHelper = require '../lib/uri-helper'

describe "LivePreviewView", ->
  [file, preview] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    spyOn(LivePreviewView.prototype, 'render').andCallThrough()

    waitsForPromise ->
      atom.workspace.open("subdir/file.markdown")

    runs ->
      editorId = atom.workspace.getActiveEditor().id
      uri = UriHelper.uriForEditorId("test-protocol:", editorId)
      preview = new LivePreviewView(uri)

  afterEach ->
    preview.destroy()

  describe "::constructor", ->
    it "shows a loading spinner and renders the preview", ->
      preview.renderer.showLoading(preview)
      expect(preview.find('.live-preview-spinner')).toExist()

      preview.render()

      expect(preview.find("code")).toExist()

    it "shows an error message when there is an error", ->
      preview.renderer.showError("Not a real file", preview)
      expect(preview.text()).toContain "Failed"

  describe "serialization", ->
    newPreview = null

    afterEach ->
      newPreview.destroy()

    it "recreates the file when serialized/deserialized", ->
      newPreview = atom.deserializers.deserialize(preview.serialize())
      expect(newPreview.getPath()).toBe preview.getPath()

    it "serializes the editor id when opened for an editor", ->
      preview.destroy()

      waitsForPromise ->
        atom.workspace.open('new.markdown')

      runs ->
        editorId = atom.workspace.getActiveEditor().id
        uri = UriHelper.uriForEditorId("test-protocol:", editorId)
        preview = new LivePreviewView(uri)
        expect(preview.getPath()).toBe atom.workspace.getActiveEditor().getPath()

        newPreview = atom.deserializers.deserialize(preview.serialize())
        expect(newPreview.getPath()).toBe preview.getPath()
