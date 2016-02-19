{View} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'
utils = require './utils'
Stream = require './stream'
Palette = require './palette'

module.exports =
class GulpTaskLauncherView extends View
    processes = {}
    curr = ''
    prev = ''
    @content: ->
        @div class: "gulp-task-launcher", outlet: 'Panel', =>
            @ul class: "tasks", outlet: 'TaskArea'
            @div class: "messages", outlet: 'MessageArea'

    initialize: (serializeState) ->
        atom.commands.add 'atom-workspace',
            "gulp-task-launcher:toggle": => @toggle()
        atom.commands.add 'atom-workspace',
            "gulp-task-launcher:stop": => @killProc()
        atom.commands.add 'atom-workspace',
            "gulp-task-launcher:restart": => @run(curr)
        atom.commands.add 'atom-workspace',
            "gulp-task-launcher:previous": => @run(prev)
        atom.commands.add 'atom-workspace',
            "gulp-task-launcher:default": => @runDefault()

        @click '.tasks li.task', (event) =>
            task = event.target.textContent

            switch task
                when 'Stop' then @killProc()
                when 'Restart' then @run(curr)
                when 'Previous' then @run(prev)
                when 'Default' then @runDefault()
                else
                    for t in @tasks when t is task
                        return @run(task)

    serialize: ->

    destroy: ->
        for w in @watchers
            w.dispose()
        @detach()
        @killProc()
        return

    toggle: ->
        if @hasParent()
            @destroy()

        else
            atom.workspace.addBottomPanel item: this
            @console = new Stream(@MessageArea)
            @palette = new Palette(@TaskArea)
            if not @getGulpTasks() and atom.config.get('gulp-task-launcher.useDefault')
                @runGulp(atom.config.get('gulp-task-launcher.runCommand'))
        return

    killProc: ->
        for gulpPath, process of processes
            if process
                process.kill()
                @find(".tasks li.task.running").removeClass 'running'
                @console.print 'Process terminated'
        return

    getGulpTasks: ->
        @tasks = []
        @watchers = []
        @console.reset()

        projpath = atom.project.getPaths()[0]
        unless @gulpCwd = utils.getGulpCwd(projpath)
            @console.print "Unable to find #{projpath}/**/gulpfile.[js|coffee]"
            return

        @console.print "Gulpfile found in #{@gulpCwd}"

        onOutput = (output) =>
            for task in output.split('\n') when task.length
                @tasks.push task

        onError = (output) =>
            @console.gulpErr output

        onExit = (code) =>
            if code is 0
                @console.print "#{@tasks.length} tasks found"

                if atom.config.get('gulp-task-launcher.taskOrder')
                    @tasks = @tasks.sort()
                @palette.buildTaskList(@tasks, @watchers)

                for task in @tasks
                    watch = atom.config.onDidChange "gulp-task-launcher.#{task}", ({newValue, previous}) => @palette.buildTaskList()
                    @watchers.push watch

            else
                @console.gulpExit(code)

        @runGulp '--tasks-simple', onOutput, onError, onExit
        return

    run: (task) ->
        @killProc()
        @runGulp(task)
        return

    runGulp: (task, stdout, stderr, exit) ->
        command = 'gulp'
        if curr isnt task
            prev = curr
            curr = task
        args = [task, '--color']
        unless task is '--tasks-simple'
            @console.printType "text-highlighted start", "Starting #{command} #{args[0]}..."

        gulpPath = @gulpCwd
        options = {
            cwd: @gulpCwd
        }

        stdout or= (output) => @console.gulpOut(output)
        stderr or= (code) => @console.gulpErr(code)
        exit or= (code) => @exit(code)

        newProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
        newProcess.onWillThrowError (error) =>
            @console.printError "Error starting gulp process: #{error.error.message}"
            error.handle()
        processes[@gulpCwd] = newProcess;

        @find(".tasks li.task.running").removeClass 'running'
        @find(".tasks li.task##{task}").addClass 'running'
        return

    runDefault: ->
        if atom.config.get('gulp-task-launcher.useDefault')
            @run(atom.config.get('gulp-task-launcher.runCommand'))
        else
            @run('default')
        return

    exit: (code) ->
        @console.gulpExit(code)
        @find(".tasks li.task.running").removeClass 'running'
