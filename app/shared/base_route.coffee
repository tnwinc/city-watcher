Ember = require 'ember'

module.exports = Ember.Route.extend

  beforeModel: (transition)->
    unless @store.fetch('host') && @store.fetch('builds')?.length
      @controllerFor('configure').set 'attemptedTransition', transition
      @transitionTo 'configure'
