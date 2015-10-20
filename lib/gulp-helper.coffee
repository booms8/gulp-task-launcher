GulpHelperView = require './gulp-helper-view'

module.exports =
    gulpHelperView: null

    config:
        runCommand:
            title: 'Gulp task'
            description: 'Gulp task that will be executed on launch.'
            type: 'string'
            default: 'default'

    activate: (state) ->
        @gulpHelperView = new GulpHelperView(state.gulpHelperViewState)

    deactivate: ->
        @gulpHelperView.destroy()

    serialize: ->
        gulpHelperViewState: @gulpHelperView.serialize()
