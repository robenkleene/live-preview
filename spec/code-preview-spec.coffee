{WorkspaceView} = require 'atom'
path = require 'path'
temp = require 'temp'
wrench = require 'wrench'
fs = require 'fs-plus'
CodePreviewView = require '../lib/code-preview/code-preview-view'

# Configuration
PACKAGE = 'code-preview'
COMMAND = "#{PACKAGE}:toggle"

describe "Code preview package", ->
  beforeEach ->
    fixturesPath = path.join(__dirname, 'fixtures')
    tempPath = temp.mkdirSync('atom')
    wrench.copyDirSyncRecursive(fixturesPath, tempPath, forceDelete: true)
    atom.project.setPath(tempPath)
    jasmine.unspy(window, 'setTimeout') # Prevent tests that modify the editor form timing out

    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    atom.config.set "#{PACKAGE}.liveUpdate", true
    spyOn(CodePreviewView.prototype, 'render').andCallThrough()

    waitsForPromise ->
      atom.packages.activatePackage(PACKAGE)

  describe "when a preview has not been created for the file", ->
    beforeEach ->
      atom.workspaceView.attachToDom() # `toHaveFocus()` test fails without this

    it "splits the current pane to the right with a preview for the file", ->
      waitsForPromise ->
        atom.workspace.open("subdir/file.markdown")

      runs ->
        atom.workspaceView.getActiveView().trigger COMMAND

      waitsFor ->
        CodePreviewView::render.callCount > 0

      runs ->
        expect(atom.workspaceView.getPaneViews()).toHaveLength 2
        [editorPane, previewPane] = atom.workspaceView.getPaneViews()
        expect(editorPane.items).toHaveLength 1
        preview = previewPane.getActiveItem()
        expect(preview).toBeInstanceOf(CodePreviewView)
        expect(preview.getPath()).toBe atom.workspace.getActivePaneItem().getPath()
        expect(editorPane).toHaveFocus()

    describe "when the editor's path does not exist", ->
      it "splits the current pane to the right with a markdown preview for the file", ->
        waitsForPromise ->
          atom.workspace.open("new.markdown")

        runs ->
          atom.workspaceView.getActiveView().trigger COMMAND

        waitsFor ->
          CodePreviewView::render.callCount > 0

        runs ->
          expect(atom.workspaceView.getPaneViews()).toHaveLength 2
          [editorPane, previewPane] = atom.workspaceView.getPaneViews()

          expect(editorPane.items).toHaveLength 1
          preview = previewPane.getActiveItem()
          expect(preview).toBeInstanceOf(CodePreviewView)
          expect(preview.getPath()).toBe atom.workspace.getActivePaneItem().getPath()
          expect(editorPane).toHaveFocus()

    describe "when the editor does not have a path", ->
      it "splits the current pane to the right with a preview for the file", ->
        waitsForPromise ->
          atom.workspace.open("")

        runs ->
          atom.workspaceView.getActiveView().trigger COMMAND

        waitsFor ->
          CodePreviewView::render.callCount > 0

        runs ->
          expect(atom.workspaceView.getPaneViews()).toHaveLength 2
          [editorPane, previewPane] = atom.workspaceView.getPaneViews()

          expect(editorPane.items).toHaveLength 1
          preview = previewPane.getActiveItem()
          expect(preview).toBeInstanceOf(CodePreviewView)
          expect(preview.getPath()).toBe atom.workspace.getActivePaneItem().getPath()
          expect(editorPane).toHaveFocus()

    describe "when the path contains a space", ->
      it "renders the preview", ->
        waitsForPromise ->
          atom.workspace.open("subdir/file with space.md")

        runs ->
          atom.workspaceView.getActiveView().trigger COMMAND

        waitsFor ->
          CodePreviewView::render.callCount > 0

        runs ->
          expect(atom.workspaceView.getPaneViews()).toHaveLength 2
          [editorPane, previewPane] = atom.workspaceView.getPaneViews()

          expect(editorPane.items).toHaveLength 1
          preview = previewPane.getActiveItem()
          expect(preview).toBeInstanceOf(CodePreviewView)
          expect(preview.getPath()).toBe atom.workspace.getActivePaneItem().getPath()
          expect(editorPane).toHaveFocus()

    describe "when the path contains accented characters", ->
      it "renders the preview", ->
        waitsForPromise ->
          atom.workspace.open("subdir/áccéntéd.md")

        runs ->
          atom.workspaceView.getActiveView().trigger COMMAND

        waitsFor ->
          CodePreviewView::render.callCount > 0

        runs ->
          expect(atom.workspaceView.getPaneViews()).toHaveLength 2
          [editorPane, previewPane] = atom.workspaceView.getPaneViews()

          expect(editorPane.items).toHaveLength 1
          preview = previewPane.getActiveItem()
          expect(preview).toBeInstanceOf(CodePreviewView)
          expect(preview.getPath()).toBe atom.workspace.getActivePaneItem().getPath()
          expect(editorPane).toHaveFocus()

  describe "when a preview has been created for the file", ->
    [editorPane, previewPane, preview] = []

    beforeEach ->
      atom.workspaceView.attachToDom()

      waitsForPromise ->
        atom.workspace.open("subdir/file.markdown")

      runs ->
        atom.workspaceView.getActiveView().trigger COMMAND

      waitsFor ->
        CodePreviewView::render.callCount > 0

      runs ->
        [editorPane, previewPane] = atom.workspaceView.getPaneViews()
        preview = previewPane.getActiveItem()
        CodePreviewView::render.reset()

    it "closes the existing preview when toggle is triggered a second time on the editor", ->
      atom.workspaceView.getActiveView().trigger COMMAND

      [editorPane, previewPane] = atom.workspaceView.getPaneViews()
      expect(editorPane).toHaveFocus()
      expect(previewPane?.activeItem).toBeUndefined()

    it "closes the existing preview when toggle is triggered on it and it has focus", ->
      previewPane.focus()
      atom.workspaceView.getActiveView().trigger COMMAND

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
            CodePreviewView::render.reset()
            editor.setText("Hey!")

          waitsFor ->
            CodePreviewView::render.callCount > 0

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
            CodePreviewView::render.reset()
            editorPane.focus()
            editor.setText("Hey!")

          waitsFor ->
            CodePreviewView::render.callCount > 0

          runs ->
            expect(editorPane).toHaveFocus()
            expect(previewPane.getActiveItem()).toBe preview

      describe "when the liveUpdate config is set to false", ->
        it "only re-renders the markdown when the editor is saved, not when the contents are modified", ->
          atom.config.set "#{PACKAGE}.liveUpdate", false
          contentsModifiedHandler = jasmine.createSpy('contents-modified')
          atom.workspace.getActiveEditor().getBuffer().on 'contents-modified', contentsModifiedHandler
          atom.workspace.getActiveEditor().setText('ch ch changes')

          waitsFor ->
            contentsModifiedHandler.callCount > 0

          runs ->
            expect(CodePreviewView::render.callCount).toBe 0
            atom.workspace.getActiveEditor().save()
            expect(CodePreviewView::render.callCount).toBe 1

  describe "when the editor's path changes", ->
    it "updates the preview's title", ->
      titleChangedCallback = jasmine.createSpy('titleChangedCallback')

      waitsForPromise ->
        atom.workspace.open("subdir/file.markdown")

      runs ->
        atom.workspaceView.getActiveView().trigger COMMAND

      waitsFor ->
        CodePreviewView::render.callCount > 0

      runs ->
        [editorPane, previewPane] = atom.workspaceView.getPaneViews()
        preview = previewPane.getActiveItem()
        expect(preview.getTitle()).toBe 'file.markdown Code Preview'

        titleChangedCallback.reset()
        preview.one('title-changed', titleChangedCallback)
        newPath = path.join(path.dirname(atom.workspace.getActiveEditor().getPath()), 'file2.md')
        fs.renameSync(atom.workspace.getActiveEditor().getPath(), newPath)

      waitsFor ->
        titleChangedCallback.callCount is 1

  describe "sanitization", ->
    it "removes script tags and attributes that commonly contain inline scripts", ->
      waitsForPromise ->
        atom.workspace.open("subdir/evil.md")

      runs ->
        atom.workspaceView.getActiveView().trigger COMMAND

      waitsFor ->
        CodePreviewView::render.callCount > 0

      runs ->
        [editorPane, previewPane] = atom.workspaceView.getPaneViews()
        preview = previewPane.getActiveItem()
        expect(preview[0].innerHTML).toBe """
          <div><pre><code>hello


          <img>
          world
          </code></pre></div>
        """

  describe "when the markdown contains an <html> tag", ->
    it "does not throw an exception", ->
      waitsForPromise ->
        atom.workspace.open("subdir/html-tag.md")

      runs ->
        atom.workspaceView.getActiveView().trigger COMMAND

      waitsFor ->
        CodePreviewView::render.callCount > 0

      runs ->
        [editorPane, previewPane] = atom.workspaceView.getPaneViews()
        preview = previewPane.getActiveItem()
        expect(preview[0].innerHTML).toBe """
          <div><pre><code>content
          </code></pre></div>
        """
