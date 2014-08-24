SubclassedViewManager = require './fixtures/subclassed-view-manager'
SubclassedView = require './fixtures/subclassed-view'
{WorkspaceView} = require 'atom'

describe "SubclassedViewManager", ->
  viewManager = null
  previewPane = null

  beforeEach ->
    viewManager = new SubclassedViewManager("test-protocol:")
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    spyOn(SubclassedView.prototype, 'render').andCallThrough()

    waitsForPromise ->
      atom.workspace.open("subdir/file.markdown")

    runs ->
      viewManager.togglePreview()

    waitsFor ->
      SubclassedView::render.callCount > 0

  it "creates a preview pane", ->

    runs ->
      expect(atom.workspaceView.getPaneViews()).toHaveLength 2
      [editorPane, previewPane] = atom.workspaceView.getPaneViews()
      expect(previewPane.getActiveItem()).toBeInstanceOf(SubclassedView)

  describe "the preview pane", ->
    it "is a subclass of SubclassedView", ->

    it "it has the right protocol", ->
