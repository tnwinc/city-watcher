App.ConfigureController = Ember.Controller.extend

  buildFilter: ''
  errors: []

  unselectedBuilds: (->
    selectedBuilds = @get 'selectedBuilds'
    _.reject @get('builds'), (build)->
      _.findWhere selectedBuilds, id: build.id
  ).property 'builds.@each', 'selectedBuilds.@each'

  filteredBuilds: (->
    filter = @get('buildFilter').toLowerCase()
    _.filter @get('unselectedBuilds'), (build)->
      buildName = build.name.toLowerCase()
      projectName = build.projectName.toLowerCase()
      buildName.indexOf(filter) >= 0 or projectName.indexOf(filter) >= 0
  ).property 'unselectedBuilds.@each', 'buildFilter'

  projectsAndBuilds: (->
    projects = _.groupBy @get('filteredBuilds'), (build)->
      build.projectId

    _.map projects, (builds, id)->
      id: id
      name: builds[0].projectName
      builds: builds
  ).property 'filteredBuilds.@each'

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
    if _.isEmpty @get('selectedBuilds')
      errors.addObject 'You must add at least one build'

  hasErrors: Ember.computed.notEmpty 'errors'

  actions:

    addSelectedBuild: (build)->
      @get('selectedBuilds').addObject build

    removeSelectedBuild: (build)->
      @get('selectedBuilds').removeObject build

    clearErrors: ->
      @set 'errors', []

    save: ->
      @_validate()
      return if @get 'errors.length'

      App.teamCity.updateHost @get('host')
      App.settings.updateValue 'builds', @get('selectedBuilds')

      attemptedTransition = @get 'attemptedTransition'
      if attemptedTransition and attemptedTransition.targetName isnt 'configure'
        attemptedTransition.retry()
        @set 'attemptedTransition', null
      else
        @transitionToRoute 'builds'
