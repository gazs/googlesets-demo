(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  $(document).ready(function() {
    var InputsView, Suggestion, SuggestionsView, TextInput, Word, WordList;
    Word = (function() {
      function Word() {
        Word.__super__.constructor.apply(this, arguments);
      }
      __extends(Word, Backbone.Model);
      return Word;
    })();
    WordList = (function() {
      function WordList() {
        WordList.__super__.constructor.apply(this, arguments);
      }
      __extends(WordList, Backbone.Collection);
      WordList.prototype.model = Word;
      return WordList;
    })();
    TextInput = (function() {
      function TextInput() {
        this.doStuffOnKeyPress = __bind(this.doStuffOnKeyPress, this);;
        this.deleteMe = __bind(this.deleteMe, this);;
        this.addNew = __bind(this.addNew, this);;
        this.render = __bind(this.render, this);;        TextInput.__super__.constructor.apply(this, arguments);
      }
      __extends(TextInput, Backbone.View);
      TextInput.prototype.template = _.template($('#input').html());
      TextInput.prototype.events = {
        'click .add': 'addNew',
        'click .remove': 'deleteMe',
        'keypress input': 'doStuffOnKeyPress'
      };
      TextInput.prototype.initialize = function() {
        return this.model.bind('all', this.render);
      };
      TextInput.prototype.render = function() {
        $(this.el).html(this.template(this.model.toJSON()));
        return this;
      };
      TextInput.prototype.addNew = function() {
        this.model.set({
          value: this.$('input').val()
        });
        return this.collection.add({
          value: ''
        });
      };
      TextInput.prototype.deleteMe = function() {
        this.collection.remove(this.model);
        return this.remove();
      };
      TextInput.prototype.doStuffOnKeyPress = function(e) {
        if (e.keyCode !== 13) {
          return;
        }
        return this.addNew();
      };
      return TextInput;
    })();
    InputsView = (function() {
      function InputsView() {
        this.addOne = __bind(this.addOne, this);;        InputsView.__super__.constructor.apply(this, arguments);
      }
      __extends(InputsView, Backbone.View);
      InputsView.prototype.collection = new WordList;
      InputsView.prototype.el = $('#inputlist');
      InputsView.prototype.initialize = function() {
        this.collection.bind('add', this.addOne);
        return this.collection.add({
          value: 'egy'
        });
      };
      InputsView.prototype.addOne = function(word) {
        var one;
        one = new TextInput({
          model: word,
          collection: this.collection
        });
        $(this.el).append(one.render().el);
        return one.$('input')[0].focus();
      };
      return InputsView;
    })();
    Suggestion = (function() {
      function Suggestion() {
        this.addMeToTheWords = __bind(this.addMeToTheWords, this);;        Suggestion.__super__.constructor.apply(this, arguments);
      }
      __extends(Suggestion, Backbone.View);
      Suggestion.prototype.events = {
        'click': 'addMeToTheWords'
      };
      Suggestion.prototype.render = function() {
        $(this.el).html(this.model.get('value'));
        return this;
      };
      Suggestion.prototype.addMeToTheWords = function() {
        var uccso;
        uccso = inputsview.collection.last();
        if (uccso.get('value') === '') {
          uccso.set({
            value: this.model.get('value')
          });
          return inputsview.collection.add(new Word({
            value: ''
          }));
        } else {
          console.log("nem az az ág");
          return inputsview.collection.add(this.model);
        }
      };
      return Suggestion;
    })();
    SuggestionsView = (function() {
      function SuggestionsView() {
        this.getSuggestions = __bind(this.getSuggestions, this);;        SuggestionsView.__super__.constructor.apply(this, arguments);
      }
      __extends(SuggestionsView, Backbone.View);
      SuggestionsView.prototype.collection = new WordList;
      SuggestionsView.prototype.el = $('#suggestionsbox');
      SuggestionsView.prototype.initialize = function() {
        this.inputs = this.options.inputs;
        return this.inputs.bind('add', this.getSuggestions);
      };
      SuggestionsView.prototype.addOne = function(suggestion) {
        var one, word;
        word = new Word({
          value: suggestion
        });
        one = new Suggestion({
          model: word,
          collection: this.collection
        });
        return this.el.append(one.render().el);
      };
      SuggestionsView.prototype.getSuggestions = function() {
        var words;
        console.log("suggestion");
        words = this.inputs.pluck('value');
        return $.get("/sets/large/" + (JSON.stringify(words)), __bind(function(results) {
          $(this.el).html("");
          return _.each(JSON.parse(results), __bind(function(result) {
            if (__indexOf.call(words, result) < 0) {
              return this.addOne(result);
            }
          }, this));
        }, this));
      };
      return SuggestionsView;
    })();
    window.inputsview = new InputsView;
    return window.suggestionsview = new SuggestionsView({
      inputs: inputsview.collection
    });
  });
}).call(this);
