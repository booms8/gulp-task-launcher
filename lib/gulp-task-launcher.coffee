gulpTaskLauncherView = require './gulp-task-launcher-view'

module.exports =
    gulpTaskLauncherView: null

    config:
        runCommand:
            title: 'Gulp task'
            description: 'Gulp task that will be executed on launch.'
            type: 'string'
            default: 'default'
        gulpPath:
            title: 'Gulp directory'
            description: 'Directory in which to run gulp (contains the gulpfile)'
            type: 'string'
            default: atom.project.getPaths()[0]

    activate: (state) ->
        @gulpTaskLauncherView = new gulpTaskLauncherView(state.gulpTaskLauncherViewState)

    deactivate: ->
        @gulpTaskLauncherView.destroy()

    serialize: ->
        gulpTaskLauncherViewState: @gulpTaskLauncherView.serialize()
