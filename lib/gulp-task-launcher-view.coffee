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
      for gulpPath, process of processes
        if process
          process.kill()
      for t in @tasks when t is task
        return @runGulp(task)

  serialize: ->

  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
      for gulpPath, process of processes
        if process
          process.kill()
    else
      atom.workspace.addBottomPanel item: this
      @getGulpTasks()
      if atom.config.get ('gulp-task-launcher.useDefault')
        @runGulp(atom.config.get('gulp-task-launcher.runCommand'))

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
      @MessageArea.append "<div class='text-highighted'>Unable to find #{projpath}/**/gulpfile.[js|coffee]</div>"
      return

    @MessageArea.append "<div class='text-highighted'>Using #{@gulpCwd}/#{@gulpFile}</div>"
    @MessageArea.append "<div class='text-highighted'>Retrieving list of gulp tasks</div>"

    onOutput = (output) =>
      for task in output.split('\n') when task.length
        @tasks.push task

    onError = (output) =>
      @gulpErr(output)

    onExit = (code) =>
      if code is 0
        for task in @tasks.sort()
          @TaskArea.append "<li id='#{task}' class='task'>#{task}</li>"
        @MessageArea.append "<div class='text-highighted'>#{@tasks.length} tasks found</div>"

      else
        @gulpExit(code)

    @runGulp '--tasks-simple', onOutput, onError, onExit
    return

  runGulp: (task, stdout, stderr, exit) ->
    command = 'gulp'
    args = [task, '--color']
    @MessageArea.append "<div class='text-highighted start'>Starting #{command} #{args[0]}...</div>"

    gulpPath = @gulpCwd
    options = {
        cwd: @gulpCwd
    }

    stdout or= (output) => @gulpOut(output)
    stderr or= (code) => @gulpErr(code)
    exit or= (code) => @gulpExit(code)

    newProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
    newProcess.onWillThrowError (error) =>
      @MessageArea.append "<div class='text-error'>Error starting gulp process: #{error.error.message}</div>"
      error.handle()
    processes[@gulpCwd] = newProcess;

    @find(".tasks li.task.running").removeClass 'running'
    @find(".tasks li.task##{task}").addClass 'running'

    return

  setScroll: =>
    @MessageArea.scrollTop(@MessageArea[0].scrollHeight)
    return

  gulpOut: (output) =>
    for line in output.split("\n").filter((lineRaw) -> lineRaw isnt '')
      stream = converter.toHtml(line);
      @MessageArea.append "<div class='text-highighted'>#{stream}</div>"
    @setScroll()
    return

  gulpErr: (code) =>
    @MessageArea.append "<div class='text-error'>Error Code: #{code}</div>"
    @setScroll()
    return

  gulpExit: (code) =>
    if code isnt 0
      @MessageArea.append "<div class='text-error'>Exited with error code: #{code}</div>"
      @setScroll()
    else
      @MessageArea.append "<div class='text-highighted'>Exited normally</div>"
      @setScroll()
    @find(".tasks li.task.running").removeClass 'running'
    return
