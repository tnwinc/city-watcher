TeamCity = Ember.Object.extend

  init: ->
    @set 'host', App.settings.getValue 'host', '10.32.2.99'

  updateHost: (host)->
    @set 'host', host
    App.settings.updateString 'host', host

  baseUrl: (->
    "http://#{@get 'host'}/guestAuth/app/rest/"
  ).property 'host'

  queryTeamCity: (url)->
    new Ember.RSVP.Promise (resolve, reject)=>
      $.getJSON "#{@get 'baseUrl'}#{url}"
        .then (value)-> resolve value
        .fail (error)-> reject error

  getBuild: (id)->
    @queryTeamCity "builds/id:#{id}"

  getAllBuilds: ->
    return Ember.RSVP.resolve [] unless @get 'host'

    @queryTeamCity('buildTypes').then (result)->
      builds = _.map result.buildType, (buildType)->
        _.pick buildType, 'id', 'name', 'projectId', 'projectName'

      projects = _.groupBy builds, (build)->
        build.projectId

      _.map projects, (builds, id)->
        id: id
        name: builds[0].projectName
        builds: _.map builds, (build)->
          _.pick build, 'id', 'name'

App.teamCity = TeamCity.create()
