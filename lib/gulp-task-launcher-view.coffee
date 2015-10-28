{View} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'
Convert = require 'ansi-to-html'
converter = new Convert()
module.exports =
class GulpHelperView extends View
  processes = {}
  @content: ->
    @div =>
      @div class: "gulp-task-launcher tool-panel panel-bottom", outlet: 'Panel', =>
        @div class: "panel-body padded", outlet: 'MessageArea'

  initialize: (serializeState) ->
    atom.commands.add 'atom-workspace',
      "gulp-task-launcher:toggle": => @toggle()

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
      @runGulp()

  runGulp: ->
    command = 'gulp'
    args = [atom.config.get('gulp-task-launcher.runCommand'), '--color']
    @MessageArea.append "<div class='text-highighted'>Starting #{command} #{args[0]}...</div>"

    gulpPath = atom.config.get('gulp-task-launcher.gulpPath')
    if !gulpPath or !gulpPath.length
      @MessageArea.append "<div class='text-error'>No project path found!</div>"

    options = {
        cwd: gulpPath
    }

    stdout = (output) => @gulpOut(output, gulpPath)
    stderr = (code) => @gulpErr(code, gulpPath)
    exit = (code) => @gulpExit(code, gulpPath)

    newProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
    newProcess.onWillThrowError (error) =>
      @MessageArea.append "<div class='text-error'>Error starting gulp process: #{error.error.message}</div>"
      error.handle()
    processes[gulpPath] = newProcess;

  setScroll: =>
    @Panel.scrollTop(@Panel[0].scrollHeight)

  gulpOut: (output, gulpPath) =>
    for line in output.split("\n").filter((lineRaw) -> lineRaw isnt '')
      stream = converter.toHtml(line);
      @MessageArea.append "<div class='text-highighted'>#{stream}</div>"
    @setScroll()

  gulpErr: (code, gulpPath) =>
    @MessageArea.append "<div class='text-error'>Error Code: #{code}</div>"
    @setScroll()

  gulpExit: (code, gulpPath) =>
    if code isnt 0
      @MessageArea.append "<div class='text-error'>Exited with error code: #{code}</div>"
      @setScroll()
    else
      @MessageArea.append "<div class='text-highighted'>Exited normally</div>"
      @setScroll()
