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
    render: ->
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
      @collection.add value: 'egy'
    addOne: (word) =>

      one = new TextInput model:word, collection: @collection
      $(@el).append one.render().el
      one.$('input')[0].focus()

  class Suggestion extends Backbone.View
    events:
      'click': 'addMeToTheWords'
    render: ->
      $(@el).html @model.get 'value'
      return this


    addMeToTheWords: ->
      uccso = inputsview.collection.last()
      console.log uccso.toJSON()
      if uccso.get 'value' is ''
        uccso.set
          value: @model.get 'value'
      else
        inputsview.collection.add @model


  class SuggestionsView extends Backbone.View
    collection: new WordList
    el: $('#suggestionsbox')
    initialize: ->
      @inputs = @options.inputs
      @inputs.bind 'add', @getSuggestions
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
  window.suggestionsview = new SuggestionsView
    inputs: inputsview.collection

