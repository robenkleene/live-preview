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
      console.log "creating preview"
      preview = new LivePreviewView(atom.workspace.getActiveEditor().id)

  afterEach ->
    preview.destroy()

  describe "::constructor", ->
    it "shows a loading spinner and renders the preview", ->
      preview.showLoading()
      expect(preview.find('.live-preview-spinner')).toExist()

      preview.render()  # Call render manually because this is normally called external to LivePreviewView

      waitsFor ->
        LivePreviewView::render.callCount > 0

      runs ->
        expect(preview.find("code")).toExist()
