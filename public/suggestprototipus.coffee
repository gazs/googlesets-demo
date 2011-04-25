

# van egy pár dolog, ami a DOM-ban keresne dolgokat, egyébként valszeg csúnya dolog document.ready-re
# várni.
$(document).ready ->
  # Mindennek az alapja ez a Model. Minden, amivel foglalkozunk, egy szó
  # .. aminek egyébként lesz mindig egy value paramétere,
  # de mivel nem validáljuk meg semmi, ezért itt ezzel nem is kell foglalkozzunk
  class Word extends Backbone.Model

  # lesznek olyanok is, hogy több szó van együtt, ezt hívjuk mondjuk listának.
  # Kicsit spoileres,de elárulom, két ilyen listánk lesz később.
  class WordList extends Backbone.Collection
    model: Word


  class TextInput extends Backbone.View
    # ez egy <script> tagbe van csomagolva az index.html-ben. A template funkció
    # az Underscore.js-ből jön, azért ezt használjuk, mert az Underscore amúgy is kell
    # a Backbone-hoz, egyébként a legundorítóbb templatenyelv ever, php-szerűen lehet/kell
    # belehányni a javascript kódot...
    template: _.template($('#input').html())

    # A Backbone felcsatolja neked az eseménykezelőket a View-hoz, amikor berakod a DOM-ba,
    # meg lekapcsolja őket, ha kiszeded. Tisztább, mintha te magad gamatkodnál vele.
    events:
      'click .add': 'addNew'
      'click .remove': 'deleteMe'
      'keypress input': 'doStuffOnKeyPress'
      'blur input': 'doStuffOnKeyPress'

    # Értelemszerűen inicializáláskor fut le ez a metódus
    initialize: ->
      # Feliratkozunk minden változásra (Lehetne még: add, remove, refresh, change, error)
      @model.bind 'all', @render

    render: =>
      # az @el-t -- ha csak nem adunk neki meglevő sajátot, ő hozza létre. Alapből egy <div>
      # de ha adunk neki más @tagName-et, akkor azt fogja használni (megadható még @className meg @id is)
      $(@el).html @template @model.toJSON()
      # itt még nem csatoljuk hozzá a DOM-hoz
      return this

    save: =>
      # a modellünk még mindig nem foglalkozik azzal, mit öntünk bele, amíg az egy Object.
      @model.set
        value: this.$('input').val()

    addNew: =>
      # ez itt amúgy két külön dolog összemosása: mentsük el magunkat és adjunk egy új elemet a listánkhoz 
      @save()
      @collection.add value: ''

    deleteMe: =>
      # ezzel kivesszük a collectionünkből a modelljét
      @collection.remove @model
      # ezzel pedig a DOM-ból a megjelenítését
      @remove()

    doStuffOnKeyPress: (e)=>
      # ha nem enter, akkor return!!!
      if e.keyCode != 13 then return
      @addNew()

  class InputsView extends Backbone.View
    # az inputmezők listája egy szavak listájára épül
    collection: new WordList

    # csináltam is már neki egy elemet a domban, használja csak azt
    el: $('#inputlist')

    initialize: ->
      # ha a WordListünk kap új elemet, csináljunk hozzá dobozt
      @collection.bind 'add', @addOne

      # a WordListünk kap új elemet! Csinálhatunk új dobozt!
      @collection.add value: ''

      # a SuggestionsView-ra valójában sehol máshol nem hivatkozunk, de valahol létre kell hozni.
      # van neki egy saját belső collectionja is, de szüksége van ennek a collectionjára is
      @suggestionsview = new SuggestionsView inputs: @collection

    addOne: (word) =>
      # a collectionünkhöz jött egy új modell, tehát kell neki egy új view.
      # (a viewnak viszont a működéséhez tudnia kell, ki az ő modellje és az melyik collectionhöz tartozik)
      one = new TextInput model:word, collection: @collection

      # emlékeztek, amikor az előbb return this-eltünk a renderelés végén? azért kellett, hogy itt tudjuk
      # hozzáadni a DOM-hoz.
      $(@el).append one.render().el
      one.$('input')[0].focus()

  class Suggestion extends Backbone.View
    tagName: 'a'
    className: 'suggestion'
    events:
      'click': 'addMeToTheWords'
    render: ->
      # kértünk már egy <a> taget, öntsük bele a @model 'value' paraméterének értékét
      $(@el).html @model.get 'value'
      return this

    addMeToTheWords: =>
      # ha az inputok listáján az utolsó üres, akkor azt stipizzük le, ha nem, akkor muszáj egy új
      # sort kérnünk
      uccso = inputsview.collection.last()
      if uccso.get('value') == ''
        uccso.set
          value: @model.get('value')
        inputsview.collection.add new Word value: ''
      else
        inputsview.collection.add @model


  class SuggestionsView extends Backbone.View
    # ez is egy tök ugyanolyan szólista, mint a másik, csak... másik.
    collection: new WordList

    el: $('#suggestionsbox')

    initialize: ->
      # fennebb, amikor létrehoztuk az InputsView hasában ezt a View-t, megadtuk neki paraméternek az ő
      # collectionsát, ez a teljesen követhetetlen nevű inputs.
      # mivel ez egy alapból nem várt paraméter (nem model, collection, el, id, className, tagName, ilyesmi)
      # ezért az @options alá kerül alapból.
      @inputs = @options.inputs
      @inputs.bind 'all', @getSuggestions
      @getSuggestions()

    addOne: (suggestion) ->
      # a suggestion egy sima string, ezért kézzel kell belőle Word-öt csinálnunk. de amúgy pont mint fennebb.
      word = new Word value: suggestion
      one = new Suggestion model:word, collection: @collection
      @el.append one.render().el

    getSuggestions: =>
      # a pluck visszaadja a collection összes elemének bizonyos tulajdonságát.
      words = @inputs.pluck('value')

      # üres inputlistára azért mégse dolgozzunk
      return false if words.length == 1 && words[0] == ""

      $.ajax
        type: 'GET'
        url: "/sets/large/#{JSON.stringify(words)}"
        success: (results) =>
          $(@el).html("")
          # minden visszakapott szónál ...
          _.each JSON.parse(results), (result) =>
            # ... ha már nincs beírva ...
            if result not in words
              # ... adjon hozzá egy ajánlást a listára.
              @addOne(result)
        error: (xhr, type) =>
          $(@el).html "<b>se mi, se szergej, se larry nem tud erre mit javasolni. szerintem törölj párat</b>"

  window.inputsview = new InputsView

