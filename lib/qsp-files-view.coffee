{SelectListView} = require 'atom-space-pen-views'

module.exports =
class QspFilesView extends SelectListView
    initialize: (list) ->
        super
        @setItems(list)
        @storeFocusedElement()
        @panel ?= atom.workspace.addModalPanel(item: this)
        @panel.show()
        @focusFilterEditor()

    viewForItem: (item) ->
        "<li>#{item.getPath()}</li>"

    destroy: ->
        @cancel()

    confirmed: (item) ->
        console.log(item);
        @cancel()

    cancelled: ->
        @panel.hide()

    getFilterKey: ->
        'path'
