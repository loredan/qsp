{File} = require 'atom'

module.exports =
class QspDecoder
    constructor: (@data, @file) ->
        @decodeFile()

    decodeFile: ->
        prepare = @prepare()
        if !prepare
            return
        version = @readLine(prepare)
        console.log @toString(version.line)
        password = @readLine(version.next)
        console.log @toString @decode password.line
        locations = @readLine password.next
        locationsNumber = (@toString @decode locations.line).valueOf()
        console.log locationsNumber

        next = locations.next
        locations = []
        for i in [0...locationsNumber]
            location = @readLocation next
            next = location.next
            locations.push location

        console.log locations

    prepare: ->
        @config = {}
        @config.ucs2le = @data[1] == 0
        @config.crlf = @data[7 * if @config.ucs2le then 2 else 1] == 13
        @config.encodedPath = @file.getPath()
        check = @readLine(0, 9)

        if @toString(check.line) == 'QSPGAME'
            return check.next
        else
            return 0

    readLocation: (position) ->
        name = @readLine position
        description = @readLine name.next
        code = @readLine description.next
        actions = @readLine code.next

        actionsNumber = (@toString @decode actions.line).valueOf()
        next = actions.next
        actions = []
        for i in [0...actionsNumber]
            action = @readAction next
            next = action.next
            actions.push(action)

        name: @toString @decode name.line
        description: @toString @decode description.line
        code: @toString @decode code.line
        actions: actions
        next: next

    readAction: (position) ->
        picture = @readLine position
        name = @readLine picture.next
        code = @readLine name.next

        picture: @toString @decode picture.line
        name: @toString @decode name.line
        code: @toString @decode code.line
        next: code.next

    readLine: (start, max) ->
        counter = start
        line = []
        that = @
        check = ->
            if that.config.crlf
                return line[line.length - 1] == 10 and line[line.length - 2] == 13
            else
                return line[line.length - 1] == 10

        while !check() or counter >= @data.length
            line.push(@readSymbol(counter))
            counter += if @config.ucs2le then 2 else 1
            if max and line.length > max
                break

        line: line[0...if @config.crlf then -2 else -1]
        next: counter

    readSymbol: (position) ->
        code = @data[position]
        code += @data[position + 1] * 256 if @config.ucs2le
        return code

    decode: (line) ->
        for i in [0...line.length]
          line[i] += 5
        return line

    toString: (line) ->
        return String.fromCharCode.apply(@, line)

class ProjectBuilder
    constructor: (config) ->
        @directoryStack = []

    createDirectoryRecursive: (directory, callback) ->
        if directory.getParent().exists()
            that = @
            directory.create(755).then(() ->
                if that.directoryStack.length > 0
                    that.createDirectoryRecursive(that.directoryStack.pop(), callback)
                else
                    callback()
            )
        else
            @directoryStack.push(directory)
            createDirectoryRecursive(directory.getParent(), callback)
