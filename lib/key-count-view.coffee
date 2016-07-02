{Disposable, CompositeDisposable} = require 'atom'

DEFAULT_COUNT = "💩"

class KeyCountView extends HTMLElement
    init: ->
        @classList.add('key-count', 'inline-block')

        @innerSpan = @ownerDocument.createElement('span')
        @innerSpan.classList.add('key-count-inner')
        @appendChild(@innerSpan)
        @innerSpan.textContent = "Keycount"

        @lastPressedKey = ''

        @disposables = new CompositeDisposable
        @disposables.add atom.keymaps.onDidFailToMatchBinding ({keystrokes, keyboardEventTarget}) =>
            @update(keystrokes, null, keyboardEventTarget)

    refresh: (key) ->
        #styling
        @innerSpan.style.backgroundColor = @backgroundColor
        @innerSpan.style.color = @textColor
        #content
        @count = 0 unless @count?
        @count++;
        lastKey = key || @defaultKeyString

        s = @format.replace '%k', lastKey
        s = s.replace '%c', @count
        @innerSpan.textContent = s

    update: (key) ->
        if (key.replace '^', '') != (@lastPressedKey.replace '^', '')
            @refresh(key.replace '^', '')
            @lastPressedKey = key

    # Returns an object that can be retrieved when package is activated
    serialize: ->
        {
            count: @count
        }
    # Tear down any state and detach
    destroy: ->

module.exports = document.registerElement('key-count', prototype: KeyCountView.prototype, extends: 'div')
