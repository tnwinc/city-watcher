TeamCity = Ember.Object.extend

  init: ->
    @set 'host', App.settings.getValue 'host', '10.32.2.99'

  updateHost: (host)->
    @set 'host', host
    App.settings.updateString 'host', host

  urlWithHost: (host)->
    "http://#{host}/guestAuth/app/rest/"

  baseUrl: (->
    @urlWithHost @get('host')
  ).property 'host'

  queryTeamCity: (url, baseUrl = @get('baseUrl'))->
    new Ember.RSVP.Promise (resolve, reject)=>
      $.getJSON "#{baseUrl}#{url}"
        .then (value)-> resolve value
        .fail (error)-> reject error

  getBuild: (id)->
    @queryTeamCity "builds/id:#{id}"

  getAllBuilds: (host)->
    new Ember.RSVP.Promise (resolve)=>
      return resolve [] unless host

      getBuilds = @queryTeamCity('buildTypes', @urlWithHost host)

      getBuilds.then (result)->
        builds = _.map result.buildType, (buildType)->
          _.pick buildType, 'id', 'name', 'projectId', 'projectName'
        resolve builds

      getBuilds.catch -> resolve []

  getRunningBuilds: (builds)->
    sinceDate = (moment().subtract 'days', 3).format 'YYYYMMDDTHHmmssZZ'
    runningBuilds = _.map builds, (build)=>
      query = "\
        builds?\
          locator=running:all,\
          branch:branched:any,\
          buildType:#{build.id},\
          sinceDate:#{sinceDate}\
      "
      @queryTeamCity(query).then (data)->
        uniqueBuilds = _.uniq data.build, (build)-> build.branchName

        name: build.name
        builds: _.filter uniqueBuilds, (build)->
          build.status isnt 'UNKNOWN' and build.branchName isnt '<default>'

    Ember.RSVP.all(runningBuilds).then (buildTypes)->
      _.flatten _.map buildTypes, (buildType)->
        _.map buildType.builds, (build)->
          id: build.id
          running: !!build.running
          percentageComplete: build.percentageComplete
          branchName: build.branchName || buildType.name
          status: build.status.toLowerCase()

App.teamCity = TeamCity.create()
