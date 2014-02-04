App.ConfigureController = Ember.Controller.extend

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
