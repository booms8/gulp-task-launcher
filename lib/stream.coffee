Convert = require 'ansi-to-html'
converter = new Convert()

module.exports =
class Stream
    constructor: (@outputStream) ->

    reset: ->
        @outputStream.html("")

    printType: (type, text) ->
        @outputStream.append "<div class='#{type}'>#{text}</div>"
        @outputStream.scrollTop(@outputStream[0].scrollHeight)
        return

    print: (text) ->
        @printType 'text-highlighted', text
        return

    printError: (text) ->
        @printType 'text-error', text
        return

    printSuccess: (text) ->
        @printType 'text-success', text
        return

    gulpOut: (output) ->
        for line in output.split("\n").filter((lineRaw) -> lineRaw isnt '')
            text = converter.toHtml(line);
            @print text
        return

    gulpErr: (code) ->
        @printError "Error code: #{code}"
        return

    gulpExit: (code) ->
        if code isnt 0
            @printError "Exited with error code: #{code}"
        else
            @printSuccess "Exited normally"
        return
