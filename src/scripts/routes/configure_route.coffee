App.ConfigureRoute = Ember.Route.extend

  setupController: (controller)->
    controller.set 'host', App.settings.getValue 'host'
    App.teamCity.getAllBuilds().then (projects)->
      controller.set 'projects', projects
