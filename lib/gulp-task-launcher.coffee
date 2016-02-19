GulpTaskLauncherView = require './gulp-task-launcher-view'

module.exports =
    gulpTaskLauncherView: null

    config:
        useDefault:
            title: 'Run startup task'
            description: 'Enable running the startup task on launch'
            type: 'boolean'
            default: false
            order: 1
        runCommand:
            title: 'Startup task'
            type: 'string'
            default: 'default'
            order: 2
        taskOrder:
            title: 'Alphabetize Tasks'
            description: 'If set to false, tasks will be shown in the order they appear in the gulpfile'
            type: 'boolean'
            default: true
            order: 3
        tasks:
            description: 'Uncheck any tasks you do not wish to see in the tasks pane'
            type: 'array'
            order: 4
            default: []
            items:
                type: 'string'

    activate: (state) ->
        @gulpTaskLauncherView = new GulpTaskLauncherView(state.gulpTaskLauncherViewState)

    deactivate: ->
        @gulpTaskLauncherView.destroy()

    serialize: ->
        gulpTaskLauncherViewState: @gulpTaskLauncherView.serialize()
