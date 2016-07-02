KeyCountView = require './key-count-view'
{CompositeDisposable} = require 'atom'

DEFAULT_BACKGROUND_COLOR = '#2196F3';
DEFAULT_TEXT_COLOR = '#FFFFFF';
DEFAULT_FORMAT = '%c - %k'

module.exports = KeyCount =
    config:
        'format':
            type: 'string',
            default: DEFAULT_FORMAT
        'background-color':
            type: 'string',
            default: DEFAULT_BACKGROUND_COLOR
        'text-color':
            type: 'string',
            default: DEFAULT_TEXT_COLOR
    activate: (state) ->
        @state = state
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add 'atom-workspace', 'key-count:reset': => @reset()

        format = atom.config.get('statusbar-key-count.format', 'value');
        backgroundColor = atom.config.get('statusbar-key-count.background-color', 'value');
        textColor = atom.config.get('statusbar-key-count.text-color', 'value');

        @keyCountView = new KeyCountView()
        @keyCountView.init()
        @keyCountView.format = format
        @keyCountView.backgroundColor = backgroundColor
        @keyCountView.textColor = textColor
        @keyCountView.count = @state?.keyCountViewState?.count
        @keyCountView.refresh()

        colorRegex = /^#[a-f0-9]{6}$/;

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
