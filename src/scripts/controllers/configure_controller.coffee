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
      build.name.toLowerCase().indexOf(filter) >= 0
  ).property 'unselectedBuilds.@each', 'buildFilter'

  projectsAndBuilds: (->
    projects = _.groupBy @get('filteredBuilds'), (build)->
      build.projectId

    _.map projects, (builds, id)->
      id: id
      name: builds[0].projectName
      builds: builds
  ).property 'filteredBuilds.@each'

  hostUpdated: (->
    @updateBuilds()
  ).observes 'host'

  updateBuilds: _.debounce ->
    App.teamCity.getAllBuilds(@get('host')).then (builds)=>
      @set 'builds', builds
  , 500

  validate: ->
    @set 'errors', []
    errors = @get 'errors'
    if _.isEmpty @get('host')
      errors.addObject 'You must input a host'
    if _.isEmpty @get('selectedBuilds')
      errors.addObject 'You must add at least one build'

  actions:

    addSelectedBuild: (build)->
      @get('selectedBuilds').addObject build

    removeSelectedBuild: (build)->
      @get('selectedBuilds').removeObject build

    save: ->
      @validate()
      return if @get 'errors.length'

      App.teamCity.updateHost @get('host')
      App.settings.updateValue 'builds', @get('selectedBuilds')

      attemptedTransition = @get 'attemptedTransition'
      if attemptedTransition and attemptedTransition.targetName isnt 'configure'
        attemptedTransition.retry()
        @set 'attemptedTransition', null
      else
        @transitionToRoute 'builds'
