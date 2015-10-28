gulpTaskLauncherView = require './gulp-task-launcher-view'

module.exports =
    gulpTaskLauncherView: null

    config:
        useDefault:
            title: 'Run startup task'
            description: 'Enable to run the startup task on launch'
            type: 'boolean'
            default: false
        runCommand:
            title: 'Startup task'
            type: 'string'
            default: 'default'

    activate: (state) ->
        @gulpTaskLauncherView = new gulpTaskLauncherView(state.gulpTaskLauncherViewState)

    deactivate: ->
        @gulpTaskLauncherView.destroy()

    serialize: ->
        gulpTaskLauncherViewState: @gulpTaskLauncherView.serialize()
