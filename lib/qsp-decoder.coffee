{File} = require 'atom'

module.exports =
class QspDecoder
    constructor: (@data, @file) ->
        @decodedFile = new File(@file.getPath() + 'd')
        tempThis = @
        @decodedFile.create().then(() -> tempThis.decodeFile())

    decodeFile: ->
        @prepare()

    prepare: ->
        @config = {}
        @config.ucs2le = @data[1] == 0
        @config.crlf = @data[7 * if @config.ucs2le then 2 else 1] == 13
        console.log @config
        console.log @readLine(0, 9)

    readLine: (start, max) ->
        counter = start
        line = []
        tempThis = @
        check = ->
            if tempThis.config.crlf
                return line[line.length - 1] == 10 and line[line.length - 2] == 13
            else
                return line[line.length - 1] == 10

        while !check() or line.length > max
            line.push(@readSymbol(counter))
            counter += if @config.ucs2le then 2 else 1

        return line

    readSymbol: (position) ->
        code = @data[position]
        code += @data[position + 1] * 256 if @config.ucs2le
        console.log [
            position,
            @data[position],
            @data[position + 1],
            code
        ]
        return code

    decode: (line) ->
