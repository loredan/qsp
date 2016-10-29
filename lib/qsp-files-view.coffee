{SelectListView} = require 'atom-space-pen-views'

module.exports =
class QspFilesView extends SelectListView
    initialize: (list) ->
        super
        @setItems(list)
        @panel ?= atom.workspace.addModalPanel(item: this)
        @panel.show()

    viewForItem: (item) ->
        @li item.getPath()

    confirmed: (item) ->
        console.log("#{item.getPath()} was selected")
