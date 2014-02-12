App.ConfigureController = Ember.Controller.extend

  buildFilter: ''
  errors: []

  unselectedBuilds: (->
    selectedBuilds = @get 'selectedBuilds.content'
    _.reject @get('builds'), (build)->
      _.find selectedBuilds, (selectedBuild)->
        selectedBuild.get('id') is build.get('id')
  ).property 'builds.@each', 'selectedBuilds.content.@each'

  filteredBuilds: (->
    filter = @get('buildFilter').toLowerCase()
    _.filter @get('unselectedBuilds'), (build)->
      buildName = build.get('name').toLowerCase()
      projectName = build.get('projectName').toLowerCase()
      buildName.indexOf(filter) >= 0 or projectName.indexOf(filter) >= 0
  ).property 'unselectedBuilds.@each', 'buildFilter'

  projectsAndBuilds: (->
    projects = _.groupBy @get('filteredBuilds'), (build)->
      build.get('projectId')

    _.map projects, (builds, id)->
      id: id
      name: builds[0].get('projectName')
      builds: builds
  ).property 'filteredBuilds.@each'

  hasErrors: Ember.computed.notEmpty 'errors'

  hasSelectedBuilds: (->
    !!@get 'selectedBuilds.length'
  ).property 'selectedBuilds.@each'

  _hostUpdated: (->
    @_updateBuilds()
  ).observes 'host'

  _updateBuilds: _.debounce ->
    App.teamCity.getAllBuilds(@get('host')).then (builds)=>
      @set 'builds', builds
  , 500

  _validate: ->
    @set 'errors', []
    errors = @get 'errors'
    if _.isEmpty @get('host')
      errors.addObject 'You must input a host'
    if _.isEmpty @get('selectedBuilds.content')
      errors.addObject 'You must add at least one build'

  actions:

    addSelectedBuild: (build)->
      build.set 'order', @get 'selectedBuilds.length'
      @get('selectedBuilds').addObject build

    removeSelectedBuild: (build)->
      @get('selectedBuilds').removeObject build

    didSortSelectedBuilds: (order)->
      @beginPropertyChanges()
      _.each @get('selectedBuilds.content'), (selectedBuild)->
        selectedBuild.set 'order', order[selectedBuild.get('id')]
      @endPropertyChanges()

    clearErrors: ->
      @set 'errors', []

    save: ->
      @_validate()
      return if @get 'errors.length'

      App.teamCity.updateHost @get('host')
      App.settings.updateValue 'builds', @get('selectedBuilds.content')

      attemptedTransition = @get 'attemptedTransition'
      if attemptedTransition and attemptedTransition.targetName isnt 'configure'
        attemptedTransition.retry()
        @set 'attemptedTransition', null
      else
        @transitionToRoute 'builds'
