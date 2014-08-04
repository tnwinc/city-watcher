Ember = require 'ember'
App = require '../app'
$ = require 'jquery'

require '../vendor/jquery-ui.sortable'
require './components.sortable-list'

App.SortableListComponent = Ember.Component.extend

  didInsertElement: ->
    itemTag = @get 'itemTag'
    @$().sortable
      items: "> #{itemTag}"
      update: =>
        order = {}
        @$(itemTag).each (i, el)-> order[$(el).data('id')] = i
        @$().sortable 'cancel'
        @sendAction 'onUpdate', order

  # allows `yield` inside the each loop to use individual
  # item's context instead of parent context
  _yield: (context, options)->
    get = Ember.get
    view = options.data.view
    parentView = @_parentView
    template = get @, 'template'

    if template
      view.appendChild Ember.View,
        isVirtual: true
        tagName: ''
        _contextView: parentView
        template: template
        context: get view, 'context'
        controller: get parentView, 'controller'
        templateData: keywords: parentView.cloneKeywords()
