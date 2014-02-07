App.BuildsRoute = App.Route.extend

  model: ->
    App.teamCity.getRunningBuilds App.settings.getValue('builds')
