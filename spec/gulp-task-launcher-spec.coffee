GulpTaskLauncher = require '../lib/gulp-task-launcher'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "GulpTaskLauncher", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('GulpTaskLauncher')

  describe "when the gulp-task-launcher:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.gulp-task-launcher')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'gulp-task-launcher:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.gulp-task-launcher')).toExist()
        atom.workspaceView.trigger 'gulp-task-launcher:toggle'
        expect(atom.workspaceView.find('.gulp-task-launcher')).not.toExist()
