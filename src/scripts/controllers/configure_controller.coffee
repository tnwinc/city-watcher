App.ConfigureController = Ember.Controller.extend

  buildFilter: ''

  filteredProjects: (->
    filter = @get('buildFilter').toLowerCase()
    filteredProjects = []
    _.each @get('projects'), (project)->
      filteredBuilds = _.filter project.builds, (build)->
        name = build.name.toLowerCase()
        name.indexOf(filter) >= 0
      if filteredBuilds.length
        project = _.pick project, 'id', 'name'
        project.builds = filteredBuilds
        filteredProjects.push project
    filteredProjects
  ).property 'projects.@each', 'buildFilter'

  refreshBuilds: (->
    @updateHostAndProjects()
  ).observes 'host'

  updateHostAndProjects: _.debounce ->
    App.teamCity.updateHost @get('host')
    App.teamCity.getAllBuilds().then (projects)=>
      @set 'projects', projects
  , 300

  actions:

    toggleBuildSelection: (build)->
      # set build as selected

    save: ->
      attemptedTransition = @get 'attemptedTransition'
      if attemptedTransition and attemptedTransition.targetName isnt 'login'
        attemptedTransition.retry()
        @set 'attemptedTransition', null
      else
        @transitionToRoute 'builds'
