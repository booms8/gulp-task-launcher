{View} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'
Convert = require 'ansi-to-html'
converter = new Convert()
module.exports =
class GulpHelperView extends View
  processes = {}
  @content: ->
    @div =>
      @div class: "gulp-helper tool-panel panel-bottom", outlet: 'Panel', =>
        @div class: "panel-body padded", outlet: 'MessageArea'

  initialize: (serializeState) ->
    atom.commands.add 'atom-workspace',
      "gulp-helper:toggle": => @toggle()

  serialize: ->

  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
      for projectPath, process of processes
        if process
          process.kill()
    else
      atom.workspace.addBottomPanel item: this
      @runGulp()

  runGulp: ->
    command = 'gulp'
    args = [atom.config.get('gulp-helper.runCommand'), '--color']
    @MessageArea.html('<div>Starting gulp...</div>')
    @MessageArea.append "<div class='text-highighted'>#{command} #{args[0]}</div>"

    projectPath = atom.config.get('gulp-helper.gulpPath')

    #for projectPath in atom.project.getPaths()
      #do (projectPath) =>

    testPath = atom.config.get('gulp-helper.gulpPath')
    @MessageArea.append "<div class='text-highighted'>#{testPath}</div>"

    #if atom.project.getPaths().indexOf(testPath) is -1
      #projectPath = testPath

    options = {
        cwd: projectPath
    }

    stdout = (output) => @gulpOut(output, projectPath)
    stderr = (code) => @gulpErr(code, projectPath)
    exit = (code) => @gulpErr(code, projectPath)

    newProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
    newProcess.onWillThrowError (error) =>
      @MessageArea.append "<div class='text-error'><span class='folder-name'>#{projectPath}</span> Error starting gulp process: #{error.error.message}</div>"
      error.handle()
    processes[projectPath] = newProcess;

  setScroll: =>
    @Panel.scrollTop(@Panel[0].scrollHeight)

  gulpOut: (output, projectPath) =>
    for line in output.split("\n").filter((lineRaw) -> lineRaw isnt '')
      stream = converter.toHtml(line);
      @MessageArea.append "<div class='text-highighted'>#{stream}</div>"
    @setScroll()

  gulpErr: (code, projectPath) =>
    if code isnt 0
      @MessageArea.append "<div class='text-error'><span class='folder-name'>#{projectPath}</span> Error Code: #{code}</div>"
      @setScroll()

  gulpExit: (code, projectPath) =>
    @MessageArea.append "<div class='text-error'><span class='folder-name'>#{projectPath}</span> Exited with error code: #{code}</div>"
    @setScroll()
