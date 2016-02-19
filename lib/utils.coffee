fs = require 'fs'

module.exports =
    fileExists: (path) ->
        try
            fs.statSync(path)
        catch e
            return false
        return true

    getGulpCwd: (cwd) ->
        dirs = []

        gfregx = /^gulpfile(\.babel)?\.(js|coffee)/i
        for entry in fs.readdirSync(cwd) when entry.indexOf('.') isnt 0
            if gfregx.test(entry)
                return cwd

            else if entry.indexOf('node_modules') is -1
                abs = path.join(cwd, entry)
                if @fileExists abs and fs.statSync(abs).isDirectory()
                    dirs.push abs

        for dir in dirs
            if found = @getGulpCwd(dir)
                return found
        return
