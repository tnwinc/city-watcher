Ember = require 'ember'
App = require '../app'
_ = require 'lodash'

App.ConfigureController = Ember.Controller.extend

  runnerFilter: ''
  errors: []

  unselectedRunners: (->
    selectedRunners = @get 'selectedRunners.content'
    _.reject @get('builds'), (runner)->
      _.find selectedRunners, (selectedRunner)->
        selectedRunnerId = selectedRunner.get 'id'
        selectedRunnerId is runner.get('id') or selectedRunnerId is runner.get('projectId')
  ).property 'builds.@each', 'selectedRunners.content.@each'

  filteredRunners: (->
    filter = @get('runnerFilter').toLowerCase()
    _.filter @get('unselectedRunners'), (build)->
      buildName = build.get('name').toLowerCase()
      projectName = build.get('projectName').toLowerCase()
      buildName.indexOf(filter) >= 0 or projectName.indexOf(filter) >= 0
  ).property 'unselectedRunners.@each', 'runnerFilter'

  runners: (->
    projects = _.groupBy @get('filteredRunners'), (build)->
      build.get('projectId')

    _.map projects, (builds, id)->
      Ember.Object.create
        id: id
        name: builds[0].get('projectName')
        builds: builds
  ).property 'filteredRunners.@each'

  hasErrors: Ember.computed.notEmpty 'errors'

  hasSelectedRunners: (->
    !!@get 'selectedRunners.length'
  ).property 'selectedRunners.@each'

  _hostUpdated: (->
    @_updateBuilds()
  ).observes 'host'

  _updateBuilds: _.debounce ->
    @teamcity.getAllBuilds(@get('host')).then (builds)=>
      @set 'builds', builds
  , 500

  _validate: ->
    @set 'errors', []
    errors = @get 'errors'
    if _.isEmpty @get('host')
      errors.addObject 'You must input a host'
    if _.isEmpty @get('selectedRunners.content')
      errors.addObject 'You must add at least one build'

  _addRunner: (runner, type)->
    runner.set 'order', @get 'selectedRunners.length'
    runner.set 'type', type
    @get('selectedRunners').addObject runner

  _removeSelectedBuildsForProject: (project)->
    selectedRunners = @get 'selectedRunners.content'
    selectedBuilds = _.filter selectedRunners, (runner)-> runner.get('type') is 'build'
    buildsInProject = _.filter selectedBuilds, (build)-> build.get('projectId') is project.get('id')
    _.each buildsInProject, (build)->
      selectedRunners.removeObject build

  actions:

    addSelectedProject: (project)->
      @_removeSelectedBuildsForProject project
      project.set 'builds', null
      @_addRunner project, 'project'

    addSelectedBuild: (build)->
      @_addRunner build, 'build'

    removeSelectedRunner: (runner)->
      @get('selectedRunners').removeObject runner

    didSortSelectedRunners: (order)->
      @beginPropertyChanges()
      _.each @get('selectedRunners.content'), (selectedBuild)->
        selectedBuild.set 'order', order[selectedBuild.get('id')]
      @endPropertyChanges()

    toggleCollapseSelectedRunners: ->
      @toggleProperty 'collapseSelectedRunners'
      return

    clearErrors: ->
      @set 'errors', []

    save: ->
      @_validate()
      return if @get 'errors.length'

      @teamcity.updateHost @get('host')
      @store.save 'runners', @get('selectedRunners.content')

      attemptedTransition = @get 'attemptedTransition'
      if attemptedTransition and attemptedTransition.targetName isnt 'configure'
        attemptedTransition.retry()
        @set 'attemptedTransition', null
      else
        @transitionToRoute 'builds'
