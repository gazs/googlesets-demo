$(document).ready ->
  class Word extends Backbone.Model

  class WordList extends Backbone.Collection
    model: Word


  class TextInput extends Backbone.View
    template: _.template($('#input').html())
    events:
      'click .add': 'addNew'
      'click .remove': 'deleteMe'
      'keypress input': 'doStuffOnKeyPress'
    initialize: ->
      @model.bind 'all', @render
    render: =>
      $(@el).html @template @model.toJSON()
      return this
    addNew: =>
      @model.set
        value: this.$('input').val()
      @collection.add value: ''
    deleteMe: =>
      @collection.remove @model
      @remove()
    doStuffOnKeyPress: (e)=>
      if e.keyCode != 13 then return
      @addNew()

  class InputsView extends Backbone.View
    collection: new WordList
    el: $('#inputlist')
    initialize: ->
      @collection.bind 'add', @addOne
      @collection.add value: ''
      @suggestionsview = new SuggestionsView
        inputs: @collection
    addOne: (word) =>

      one = new TextInput model:word, collection: @collection
      $(@el).append one.render().el
      one.$('input')[0].focus()

  class Suggestion extends Backbone.View
    tagName: 'a'
    className: 'suggestion'
    events:
      'click': 'addMeToTheWords'
    render: ->
      $(@el).html @model.get 'value'
      return this

    addMeToTheWords: =>
      uccso = inputsview.collection.last()
      if uccso.get('value') == ''
        uccso.set
          value: @model.get('value')
        inputsview.collection.add new Word value: ''
      else
        inputsview.collection.add @model


  class SuggestionsView extends Backbone.View
    collection: new WordList
    el: $('#suggestionsbox')
    initialize: ->
      @inputs = @options.inputs
      @inputs.bind 'all', @getSuggestions
      @getSuggestions()
    addOne: (suggestion) ->
      word = new Word value: suggestion
      one = new Suggestion model:word, collection: @collection
      @el.append one.render().el
    getSuggestions: =>
      words = @inputs.pluck('value')
      $.get "/sets/large/#{JSON.stringify(words)}", (results) =>
        $(@el).html("")
        _.each JSON.parse(results), (result) =>
          if result not in words
            @addOne(result)

  window.inputsview = new InputsView

