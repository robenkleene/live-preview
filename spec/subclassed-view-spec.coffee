SubclassedView = require './fixtures/subclassed-view'
UriHelper = require '../lib/uri-helper'
{WorkspaceView} = require 'atom'

describe "SubclassedView", ->
  preview = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    spyOn(SubclassedView.prototype, 'render').andCallThrough()

    waitsForPromise ->
      atom.workspace.open("subdir/file.markdown")

    runs ->
      editorId = atom.workspace.getActiveEditor().id
      uri = UriHelper.uriForEditorId("test-protocol:", editorId)
      preview = new SubclassedView(uri)
      preview.render()

    waitsFor ->
      SubclassedView::render.callCount > 0

  afterEach ->
    preview.destroy()

  it "uses the test renderer", ->
    expect(preview.find('.rendered')).toExist()

  it "overrides the title", ->
    title = preview.getTitle()
    expect(title.indexOf("Subclassed Preview")).toBeGreaterThan(0)
