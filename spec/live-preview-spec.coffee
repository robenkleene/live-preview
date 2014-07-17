describe "Live preview package", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    waitsForPromise ->
      atom.packages.activatePackage("live-preview")

    describe "when a preview has not been created for the file", ->

      it "splits the current pane to the right with a markdown preview for the file", ->
        waitsForPromise ->
          atom.workspace.open("subdir/file.markdown")

        runs ->
          atom.workspaceView.getActiveView().trigger 'markdown-preview:toggle'

        waitsFor ->
          MarkdownPreviewView::renderMarkdown.callCount > 0

        runs ->
          expect(atom.workspaceView.getPaneViews()).toHaveLength 2
          [editorPane, previewPane] = atom.workspaceView.getPaneViews()

          expect(editorPane.items).toHaveLength 1
          preview = previewPane.getActiveItem()
          expect(preview).toBeInstanceOf(MarkdownPreviewView)
          expect(preview.getPath()).toBe atom.workspace.getActivePaneItem().getPath()
          expect(editorPane).toHaveFocus()
