{View} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'
fs = require 'fs'
path = require 'path'
Convert = require 'ansi-to-html'
converter = new Convert()

module.exports =
class GulpHelperView extends View
    processes = {}
    @content: ->
        @div =>
            @div class: "gulp-task-launcher", outlet: 'Panel', =>
                @ul class: "tasks", outlet: 'TaskArea'
                @div class: "messages", outlet: 'MessageArea'

    initialize: (serializeState) ->
        atom.commands.add 'atom-workspace',
            "gulp-task-launcher:toggle": => @toggle()

        @click '.tasks li.task', (event) =>
            task = event.target.textContent
            @killProc()
            for t in @tasks when t is task
                return @runGulp(task)

    serialize: ->

    destroy: ->
        @detach()
        @killProc()

    toggle: ->
        if @hasParent()
            @destroy()

        else
            atom.workspace.addBottomPanel item: this
            if not @getGulpTasks() and atom.config.get('gulp-task-launcher.useDefault')
                @runGulp(atom.config.get('gulp-task-launcher.runCommand'))

    killProc: ->
        for gulpPath, process of processes
            if process
                process.kill()

    getGulpCwd: (cwd) ->
        dirs = []

        gfregx = /^gulpfile(\.babel)?\.(js|coffee)/i
        for entry in fs.readdirSync(cwd) when entry.indexOf('.') isnt 0
            if gfregx.test(entry)
                @gulpFile = entry
                return cwd

            else if entry.indexOf('node_modules') is -1
                abs = path.join(cwd, entry)
                if fs.statSync(abs).isDirectory()
                    dirs.push abs

        for dir in dirs
            if found = @getGulpCwd(dir)
                return found

        return

    getGulpTasks: ->
        @tasks = []
        @TaskArea.html("")
        @MessageArea.html("")

        projpath = atom.project.getPaths()[0]
        unless @gulpCwd = @getGulpCwd(projpath)
            @lineOut "text-highighted", "Unable to find #{projpath}/**/gulpfile.[js|coffee]"
            return

        @lineOut "text-highighted", "Using #{@gulpCwd}/#{@gulpFile}"

        onOutput = (output) =>
            for task in output.split('\n') when task.length
                @tasks.push task

        onError = (output) =>
            @gulpErr(output)

        onExit = (code) =>
            if code is 0
                @lineOut "text-highighted", "#{@tasks.length} tasks found"
                for task in @tasks.sort()
                    @TaskArea.append "<li id='#{task}' class='task'>#{task}</li>"

            else
                @gulpExit(code)

        @runGulp '--tasks-simple', onOutput, onError, onExit
        return

    runGulp: (task, stdout, stderr, exit) ->
        command = 'gulp'
        args = [task, '--color']
        unless task is '--tasks-simple'
            @lineOut "text-highighted start", "Starting #{command} #{args[0]}..."

        gulpPath = @gulpCwd
        options = {
            cwd: @gulpCwd
        }

        stdout or= (output) => @gulpOut(output)
        stderr or= (code) => @gulpErr(code)
        exit or= (code) => @gulpExit(code)

        newProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
        newProcess.onWillThrowError (error) =>
            @lineOut "text-error", "Error starting gulp process: #{error.error.message}"
            error.handle()
        processes[@gulpCwd] = newProcess;

        @find(".tasks li.task.running").removeClass 'running'
        @find(".tasks li.task##{task}").addClass 'running'
        return

    lineOut: (type, text) ->
        @MessageArea.append "<div class='#{type}'>#{text}</div>"
        @MessageArea.scrollTop(@MessageArea[0].scrollHeight)
        return

    gulpOut: (output) ->
        for line in output.split("\n").filter((lineRaw) -> lineRaw isnt '')
            stream = converter.toHtml(line);
            @lineOut "text-highighted", stream
        return

    gulpErr: (code) ->
        @lineOut "text-error", "Error code: #{code}"
        return

    gulpExit: (code) ->
        if code isnt 0
            @lineOut "text-error", "Exited with error code: #{code}"
        else
            @lineOut "text-highighted", "Exited normally"
        @find(".tasks li.task.running").removeClass 'running'
        return
