KeyCountView = require './key-count-view'
{CompositeDisposable} = require 'atom'

module.exports = KeyCount =
    activate: (state) ->
        @state = state
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add 'atom-workspace', 'key-count:toggle': => @toggle()

        @keyCountView = new KeyCountView()
        @keyCountView.init()
        @keyCountView.count = @state?.keyCountViewState?.count;
        @keyCountView.refresh()

    deactivate: ->
        @subscriptions.dispose()
        @keyCountView.destroy()
        @statusBarTile?.destroy()

    serialize: ->
        keyCountViewState: @keyCountView.serialize()

    toggle: (active = undefined) ->
        @statusBarTile = @statusBar.addLeftTile
            item: @keyCountView, priority: 50

    consumeStatusBar: (statusBar) ->
        @statusBar = statusBar
        @toggle true
