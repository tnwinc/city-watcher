App.BuildsRoute = App.Route.extend

  model: ->
    App.teamCity.getRunningBuilds App.settings.getValue('builds')

  setupController: (controller, model)->
    @_super controller, model
    @_listenForBuildUpdates model

  deactivate: ->
    clearInterval @get('updateInterval')

  _listenForBuildUpdates: (model)->
    @set 'updateInterval', setInterval =>
      builds = App.settings.getValue 'builds'
      App.teamCity.getRunningBuilds(builds).then (newBuilds)=>
        @_purgeOldBuilds model, newBuilds
        for newBuild in newBuilds
          currentBuild = _.find model, (currentBuild)->
            newBuild.get('id') is currentBuild.get('id')
          if currentBuild
            props = ['running', 'percentageComplete', 'status']
            diff = @_buildsDiff currentBuild, currentBuild, props
            currentBuild.setProperties diff
          else
            model.addObject newBuild
    , 5000

  _purgeOldBuilds: (currentBuilds, newBuilds)->
    newIds = _.map newBuilds, (newBuild)-> newBuild.get 'id'
    for currentBuild in currentBuilds
      unless _.contains newIds, currentBuild.get('id')
        currentBuilds.removeObject currentBuild

  _buildsDiff: (currentBuild, newBuild, props)->
    diff = {}
    for prop in props
      if currentBuild.get(prop) isnt newBuild.get(prop)
        diff[prop] = newBuild.get prop
    diff
