App.ConfigureRoute = Ember.Route.extend

  setupController: (controller)->
    host = App.settings.getValue 'host'
    controller.set 'host', host
    controller.set 'selectedBuilds', App.settings.getValue 'builds', []
    App.teamCity.getAllBuilds(host).then (builds)->
      controller.set 'builds', builds
