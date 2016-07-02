{Disposable, CompositeDisposable} = require 'atom'

class KeyCountView extends HTMLElement
    init: ->
        @classList.add('key-count', 'inline-block')

        @innerSpan = @ownerDocument.createElement('span')
        @innerSpan.classList.add('key-count-inner')
        @appendChild(@innerSpan)
        @innerSpan.textContent = "Keycount"

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
        @lastPressedKey = key
        lastKey = @lastPressedKey || "💩"

        s = @format.replace '%k', lastKey
        s = s.replace '%c', @count
        @innerSpan.textContent = s

    update: (key) ->
        if key.charAt(0) == '^'
            @refresh(key.slice(1))

    # Returns an object that can be retrieved when package is activated
    serialize: ->
        {
            count: @count
        }
    # Tear down any state and detach
    destroy: ->

module.exports = document.registerElement('key-count', prototype: KeyCountView.prototype, extends: 'div')
