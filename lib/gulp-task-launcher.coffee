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
        gulpType:
            title: 'Gulp file type'
            description: 'Format of the gulp file'
            type: 'string'
            default: 'js'
            enum: ['js', 'coffee']

    activate: (state) ->
        @gulpTaskLauncherView = new gulpTaskLauncherView(state.gulpTaskLauncherViewState)

    deactivate: ->
        @gulpTaskLauncherView.destroy()

    serialize: ->
        gulpTaskLauncherViewState: @gulpTaskLauncherView.serialize()
