App.BuildsRoute = App.Route.extend

  model: ->
    App.teamCity.getBuilds()
