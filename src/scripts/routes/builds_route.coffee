App.BuildsRoute = App.Route.extend

  model: ->
    App.teamCity.getRunningBuilds App.settings.getValue('builds')

  setupController: (controller, model)->
    @_super controller, model

    setInterval =>
      builds = App.settings.getValue 'builds'
      App.teamCity.getRunningBuilds(builds).then (newBuilds)=>
        _.each model, (currentBuild, i)=>
          props = ['running', 'percentageComplete', 'status']
          diff = @buildsDiff currentBuild, newBuilds[i], props
          currentBuild.setProperties diff
    , 5000

  buildsDiff: (currentBuild, newBuild, props)->
    diff = {}
    for prop in props
      if currentBuild.get(prop) isnt newBuild.get(prop)
        diff[prop] = newBuild.get prop
    diff
