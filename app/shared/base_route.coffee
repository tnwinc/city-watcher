Ember = require 'ember'

module.exports = Ember.Route.extend

  beforeModel: (transition)->
    unless @store.fetch('host') && @store.fetch('runners')?.length
      @controllerFor('configure').set 'attemptedTransition', transition
      @transitionTo 'configure'
