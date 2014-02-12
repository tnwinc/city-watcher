App.ConfigureRoute = Ember.Route.extend

  setupController: (controller)->
    host = App.settings.getValue 'host'
    controller.set 'host', host

    selectedBuilds = _.map App.settings.getValue('builds', []), (selectedBuild)->
      Ember.Object.create selectedBuild
    sortableSelectedBuilds = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      content: selectedBuilds
      sortProperties: ['order']
    controller.set 'selectedBuilds', sortableSelectedBuilds

    App.teamCity.getAllBuilds(host).then (builds)->
      controller.set 'builds', builds
