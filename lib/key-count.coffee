KeyCountView = require './key-count-view'
{CompositeDisposable} = require 'atom'

DEFAULT_BACKGROUND_COLOR = '#2196F3'
DEFAULT_TEXT_COLOR = '#FFFFFF'
DEFAULT_FORMAT = '%c - %k'
DEFAULT_KEY_STRING = '💩'

module.exports = KeyCount =
    config:
        'format':
            type: 'string',
            default: DEFAULT_FORMAT,
            description: 'Format the text at the bottom, use %c for the count and %k for the key name'
        'background-color':
            type: 'string',
            default: DEFAULT_BACKGROUND_COLOR,
            description: 'Set a background color'
        'text-color':
            type: 'string',
            default: DEFAULT_TEXT_COLOR,
            description: 'Set the text color'
        'default-key-string':
            type: 'string',
            default: DEFAULT_KEY_STRING,
            description: 'The default string shown when you haven\'t yet pressed a key'
    activate: (state) ->
        @state = state
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add 'atom-workspace', 'key-count:reset': => @reset()

        format = atom.config.get('statusbar-key-count.format', 'value')
        backgroundColor = atom.config.get('statusbar-key-count.background-color', 'value')
        textColor = atom.config.get('statusbar-key-count.text-color', 'value')
        defaultKeyString = atom.config.get('statusbar-key-count.default-key-string')

        @keyCountView = new KeyCountView()
        @keyCountView.init()
        @keyCountView.format = format
        @keyCountView.backgroundColor = backgroundColor
        @keyCountView.textColor = textColor
        @keyCountView.defaultKeyString = defaultKeyString
        @keyCountView.count = @state?.keyCountViewState?.count
        @keyCountView.refresh()

        colorRegex = /^#[a-fA-F0-9]{6}$/

        _this = this
        atom.config.onDidChange 'statusbar-key-count.format', ({newValue, oldValue}) ->
            _this.keyCountView.format = newValue || DEFAULT_FORMAT
            _this.keyCountView.refresh()
        atom.config.onDidChange 'statusbar-key-count.background-color', ({newValue, oldValue}) ->
            _this.keyCountView.backgroundColor = newValue?.match colorRegex || DEFAULT_BACKGROUND_COLOR
            _this.keyCountView.refresh()
        atom.config.onDidChange 'statusbar-key-count.text-color', ({newValue, oldValue}) ->
            _this.keyCountView.textColor = newValue?.match colorRegex || DEFAULT_TEXT_COLOR
            _this.keyCountView.refresh()

    deactivate: ->
        @subscriptions.dispose()
        @keyCountView.destroy()
        @statusBarTile?.destroy()

    serialize: ->
        keyCountViewState: @keyCountView.serialize()

    reset: ->
        @keyCountView.count = 0;
        @keyCountView.refresh()

    consumeStatusBar: (statusBar) ->
        @statusBar = statusBar
        @statusBarTile = @statusBar.addLeftTile
            item: @keyCountView, priority: 50
