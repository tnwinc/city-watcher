App = require '../app'
BaseRoute = require '../shared/base_route'
_ = require 'lodash'

require './controller'
require './view'
require './builds'

App.BuildsRoute = BaseRoute.extend

  setupController: (controller)->
    @_getActiveBuilds()
      .then (builds)=>
        controller.set 'model', builds
        controller.set 'hasError', false
        @_listenForBuildUpdates controller, controller.get('model')
      .catch =>
        controller.set 'model', []
        controller.set 'hasError',  true
        @_listenForBuildUpdates controller, controller.get('model')

  deactivate: ->
    clearInterval @get('updateInterval')

  _getActiveBuilds: ->
    selectedBuilds = _.filter @store.fetch('runners'), (runner)->
      runner.type is 'build'
    @teamcity.getActiveBuilds selectedBuilds

  _listenForBuildUpdates: (controller, model)->
    @set 'updateInterval', setInterval =>
      @_getActiveBuilds()
        .then (newBuilds)=>
          controller.set 'hasError', false
          @_purgeOldBuilds model, newBuilds
          for newBuild in newBuilds
            currentBuild = _.find model, (currentBuild)->
              newBuild.get('id') is currentBuild.get('id')
            if currentBuild
              props = ['running', 'percentageComplete', 'status']
              diff = @_buildsDiff currentBuild, newBuild, props
              currentBuild.setProperties diff
            else
              model.addObject newBuild
        .catch ->
          controller.set 'hasError', true
    , 5000

  _purgeOldBuilds: (model, newBuilds)->
    currentBuilds = model.copy()
    newIds = _.map newBuilds, (newBuild)-> newBuild.get 'id'
    for currentBuild in currentBuilds
      unless _.contains newIds, currentBuild.get('id')
        model.removeObject currentBuild
    return

  _buildsDiff: (currentBuild, newBuild, props)->
    diff = {}
    for prop in props
      if currentBuild.get(prop) isnt newBuild.get(prop)
        diff[prop] = newBuild.get prop
    diff
