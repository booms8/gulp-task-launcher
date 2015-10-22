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

    for projectPath in atom.project.getPaths()
      do (projectPath) =>
        options = {
            cwd: projectPath
        }

        projectPathName = projectPath.split(path.sep).filter((path) -> path isnt '').pop()

        stdout = (output) => @gulpOut(output, projectPathName)
        stderr = (code) => @gulpErr(code, projectPathName)
        exit = (code) => @gulpErr(code, projectPathName)

        newProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
        newProcess.onWillThrowError (error) =>
          @MessageArea.append "<div class='text-error'><span class='folder-name'>#{projectPathName}</span> Error starting gulp process: #{error.error.message}</div>"
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
