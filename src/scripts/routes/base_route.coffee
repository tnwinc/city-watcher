App.Route = Ember.Route.extend

  beforeModel: (transition)->
    if not App.settings.isConfigured()
      @controllerFor('configure').set 'attemptedTransition', transition
      @transitionTo 'configure'
