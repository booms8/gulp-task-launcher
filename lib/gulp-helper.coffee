GulpHelperView = require './gulp-helper-view'

module.exports =
    gulpHelperView: null

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
        @gulpHelperView = new GulpHelperView(state.gulpHelperViewState)

    deactivate: ->
        @gulpHelperView.destroy()

    serialize: ->
        gulpHelperViewState: @gulpHelperView.serialize()
