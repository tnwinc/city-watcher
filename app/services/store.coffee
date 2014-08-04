Ember = require 'ember'
App = require '../app'

Store = Ember.Object.extend

  init: ->
    @data = JSON.parse(localStorage[App.NAMESPACE] or '{}')

  fetch: (key)->
    @data[key]

  save: (key, value)->
    if typeof key is 'string'
      value = @_setValue key, value
    else
      for itemKey, itemValue of key
        @_setValue itemKey, itemValue
      value = key

    localStorage[App.NAMESPACE] = JSON.stringify @data
    value

  _setValue: (key, value)->
    if value is null
      value = @data[key]
      delete @data[key]
    else
      @data[key] = value
    value

Ember.Application.initializer
  name: 'store'

  initialize: (container, application)->
    container.register 'store:main', Store

    application.inject 'controller', 'store', 'store:main'
    application.inject 'route', 'store', 'store:main'
    application.inject 'teamcity', 'store', 'store:main'
