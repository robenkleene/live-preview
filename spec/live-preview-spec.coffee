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
    jasmine.unspy(window, 'setTimeout') # Prevent tests that modify the editor form timing out

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
        atom.workspace.open("subdir/file.markdown")

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

    describe "when the editor does not have a path", ->
      it "splits the current pane to the right with a preview for the file", ->
        waitsForPromise ->
          atom.workspace.open("")

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

    describe "when the path contains a space", ->
      it "renders the preview", ->
        waitsForPromise ->
          atom.workspace.open("subdir/file with space.md")

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

    describe "when the path contains accented characters", ->
      it "renders the preview", ->
        waitsForPromise ->
          atom.workspace.open("subdir/áccéntéd.md")

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

  describe "when a preview has been created for the file", ->
    [editorPane, previewPane, preview] = []

    beforeEach ->
      atom.workspaceView.attachToDom()

      waitsForPromise ->
        atom.workspace.open("subdir/file.markdown")

      runs ->
        atom.workspaceView.getActiveView().trigger 'live-preview:toggle'

      waitsFor ->
        LivePreviewView::render.callCount > 0

      runs ->
        [editorPane, previewPane] = atom.workspaceView.getPaneViews()
        preview = previewPane.getActiveItem()
        LivePreviewView::render.reset()

    it "closes the existing preview when toggle is triggered a second time on the editor", ->
      atom.workspaceView.getActiveView().trigger 'live-preview:toggle'

      [editorPane, previewPane] = atom.workspaceView.getPaneViews()
      expect(editorPane).toHaveFocus()
      expect(previewPane?.activeItem).toBeUndefined()

    it "closes the existing preview when toggle is triggered on it and it has focus", ->
      previewPane.focus()
      atom.workspaceView.getActiveView().trigger 'live-preview:toggle'

      [editorPane, previewPane] = atom.workspaceView.getPaneViews()
      expect(previewPane?.activeItem).toBeUndefined()

    describe "when the editor is modified", ->
      describe "when the preview is in the active pane but is not the active item", ->
        it "re-renders the preview but does not make it active", ->
          editor = atom.workspace.getActiveEditor()
          previewPane.focus()

          waitsForPromise ->
            atom.workspace.open()

          runs ->
            LivePreviewView::render.reset()
            console.log "Waiting for render"
            editor.setText("Hey!")

          waitsFor ->
            LivePreviewView::render.callCount > 0

          runs ->
            expect(previewPane).toHaveFocus()
            expect(previewPane.getActiveItem()).not.toBe preview

      describe "when the preview is not the active item and not in the active pane", ->
        it "re-renders the preview and makes it active", ->
          editor = atom.workspace.getActiveEditor()
          previewPane.focus()

          waitsForPromise ->
            atom.workspace.open()

          runs ->
            LivePreviewView::render.reset()
            editorPane.focus()
            editor.setText("Hey!")

          waitsFor ->
            LivePreviewView::render.callCount > 0

          runs ->
            expect(editorPane).toHaveFocus()
            expect(previewPane.getActiveItem()).toBe preview
