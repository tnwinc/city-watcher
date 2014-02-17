TeamCity = Ember.Object.extend

  init: ->
    @set 'host', App.settings.getValue 'host', 'carbon-scrum'

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
          Ember.Object.create _.pick buildType, 'id', 'name', 'projectId', 'projectName'
        resolve builds

      getBuilds.catch -> resolve []

  getActiveBuilds: (builds)->
    sinceDate = (moment().subtract 'days', 1).format 'YYYYMMDDTHHmmssZZ'
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
        _.map buildType.builds, (activeBuild)->
          parentBuild = _.find builds, (build)->
            build.id is activeBuild.buildTypeId

          Ember.Object.create
            id: activeBuild.id
            running: !!activeBuild.running
            percentageComplete: activeBuild.percentageComplete
            branchName: (activeBuild.branchName || buildType.name).replace 'refs/heads/', ''
            status: activeBuild.status.toLowerCase()
            order: parentBuild.order

App.teamCity = TeamCity.create()
