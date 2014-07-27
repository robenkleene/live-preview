{WorkspaceView} = require 'atom'
path = require 'path'
temp = require 'temp'
wrench = require 'wrench'


describe "Live preview package", ->
  beforeEach ->
    fixturesPath = path.join(__dirname, 'fixtures')
    tempPath = temp.mkdirSync('atom')
    wrench.copyDirSyncRecursive(fixturesPath, tempPath, forceDelete: true)
    console.log tempPath

    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    waitsForPromise ->
      atom.packages.activatePackage("live-preview")

  describe "when a preview has not been created for the file", ->

    it "splits the current pane to the right with a preview for the file", ->
      console.log "Got here"
