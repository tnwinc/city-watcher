Ember = require 'ember'
App = require '../app'

require './components.progress-bar'

App.ProgressBarComponent = Ember.Component.extend

  classNames: ['progress-bar']

  style: (->
    "width: #{@get 'value'}%"
  ).property 'value'
