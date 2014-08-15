{WorkspaceView} = require 'atom'
LivePreviewView = require '../lib/live-preview-view'

describe "LivePreviewView", ->
  [file, preview] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    spyOn(LivePreviewView.prototype, 'render').andCallThrough()

    waitsForPromise ->
      atom.workspace.open("subdir/file.markdown")

    runs ->
      preview = new LivePreviewView({editorId: atom.workspace.getActiveEditor().id})

  afterEach ->
    preview.destroy()

  describe "::constructor", ->
    it "shows a loading spinner and renders the preview", ->
      preview.showLoading()
      expect(preview.find('.live-preview-spinner')).toExist()

      preview.render()  # Call render manually because this is normally called external to LivePreviewView

      expect(preview.find("code")).toExist()

    it "shows an error message when there is an error", ->
      preview.showError("Not a real file")
      expect(preview.text()).toContain "Failed"

  describe "serialization", ->
    newPreview = null

    afterEach ->
      newPreview.destroy()

    it "recreates the file when serialized/deserialized", ->
      console.log preview.serialize()
      newPreview = atom.deserializers.deserialize(preview.serialize())
      expect(newPreview.getPath()).toBe preview.getPath()

    it "serializes the editor id when opened for an editor", ->
      preview.destroy()

      waitsForPromise ->
        atom.workspace.open('new.markdown')

      runs ->
        preview = new LivePreviewView({editorId:atom.workspace.getActiveEditor().id})
        expect(preview.getPath()).toBe atom.workspace.getActiveEditor().getPath()

        newPreview = atom.deserializers.deserialize(preview.serialize())
        expect(newPreview.getPath()).toBe preview.getPath()
