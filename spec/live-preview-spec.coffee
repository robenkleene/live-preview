{WorkspaceView} = require 'atom'
path = require 'path'
temp = require 'temp'
wrench = require 'wrench'
LivePreviewView = require '../lib/live-preview-view'

describe "Live preview package", ->
  beforeEach ->
    fixturesPath = path.join(__dirname, 'fixtures')
    tempPath = temp.mkdirSync('atom')
    wrench.copyDirSyncRecursive(fixturesPath, tempPath, forceDelete: true)
    atom.project.setPath(tempPath)

    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    spyOn(LivePreviewView.prototype, 'render').andCallThrough()

    waitsForPromise ->
      atom.packages.activatePackage("live-preview")

  describe "when a preview has not been created for the file", ->
    beforeEach ->
      atom.workspaceView.attachToDom() # `toHaveFocus()` test fails without this

    it "splits the current pane to the right with a preview for the file", ->
      waitsForPromise ->
        atom.workspace.open("example.coffee")

      runs ->
        atom.workspaceView.getActiveView().trigger 'live-preview:toggle'

      waitsFor ->
        LivePreviewView::render.callCount > 0

      runs ->
        expect(atom.workspaceView.getPaneViews()).toHaveLength 2
        [editorPane, previewPane] = atom.workspaceView.getPaneViews()
        expect(editorPane.items).toHaveLength 1
        preview = previewPane.getActiveItem()
        expect(preview).toBeInstanceOf(LivePreviewView)
        expect(preview.getPath()).toBe atom.workspace.getActivePaneItem().getPath()
        expect(editorPane).toHaveFocus()

    describe "when the editor's path does not exist", ->
      it "splits the current pane to the right with a markdown preview for the file", ->
        waitsForPromise ->
          atom.workspace.open("new.markdown")

        runs ->
          atom.workspaceView.getActiveView().trigger 'live-preview:toggle'

        waitsFor ->
          LivePreviewView::render.callCount > 0

        runs ->
          expect(atom.workspaceView.getPaneViews()).toHaveLength 2
          [editorPane, previewPane] = atom.workspaceView.getPaneViews()

          expect(editorPane.items).toHaveLength 1
          preview = previewPane.getActiveItem()
          expect(preview).toBeInstanceOf(LivePreviewView)
          expect(preview.getPath()).toBe atom.workspace.getActivePaneItem().getPath()
          expect(editorPane).toHaveFocus()
