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
        taskOrder:
            title: 'Alphabetize Tasks'
            description: 'If set to false, tasks will be shown in the order they appear in the gulpfile'
            type: 'boolean'
            default: true

    activate: (state) ->
        @gulpTaskLauncherView = new gulpTaskLauncherView(state.gulpTaskLauncherViewState)

    deactivate: ->
        @gulpTaskLauncherView.destroy()

    serialize: ->
        gulpTaskLauncherViewState: @gulpTaskLauncherView.serialize()
