{CompositeDrawable, Directory, File} = require 'atom'
QspFilesView = require './qsp-files-view'
fs = require 'fs'
QspDecoder = require './qsp-decoder'

module.exports =
    subscriptions: null

    activate: () ->
        @subscriptions = new CompositeDisposable()

        @subscriptions.add(atom.commands.add('atom-workspace', {
            'qsp:toggle': () => @toggle(),
            'qsp:decode': () => @decode()
        }))

    deactivate: () -> @subscriptions.dispose()

    toggle: () -> console.log('Qsp was toggled!')

    decode: () ->
        files = @findQspFiles()
        view = new QspFilesView()
        view.initialize(files, @decodeQspFile)

    findQspFiles: (directory) ->
        found = []

        if !directory
            for innerDirectory in atom.project.getDirectories()
                found = found.concat(@findQspFiles(innerDirectory))
        else
            for entry in directory.getEntriesSync()
                if entry instanceof File and entry.getPath().slice((entry.getPath().lastIndexOf('.') - 1 >>> 0) + 2) == 'qsp'
                    found.push(entry)

                if entry instanceof Directory
                    found = found.concat(@findQspFiles(entry))

        return found

    decodeQspFile: (file) ->
        console.log file
        fs.readFile(file.getPath(), (error, data) ->
            if error
                console.error error
                return
            new QspDecoder(data, file)
        )
