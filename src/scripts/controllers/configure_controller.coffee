App.ConfigureController = Ember.Controller.extend

  buildFilter: ''

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

  actions:

    addSelectedBuild: (build)->
      @get('selectedBuilds').addObject build

    removeSelectedBuild: (build)->
      @get('selectedBuilds').removeObject build

    save: ->
      attemptedTransition = @get 'attemptedTransition'
      if attemptedTransition and attemptedTransition.targetName isnt 'login'
        attemptedTransition.retry()
        @set 'attemptedTransition', null
      else
        @transitionToRoute 'builds'
