TeamCity = Ember.Object.extend

  init: ->
    @set 'host', App.settings.getValue 'host'

  updateHost: (host)->
    @set 'host', host
    App.settings.updateString 'host', host

  baseUrl: (->
    @_urlWithHost @get('host')
  ).property 'host'

  getBuild: (id)->
    @_queryTeamCity url: "builds/id:#{id}"

  getAllBuilds: (host)->
    new Ember.RSVP.Promise (resolve)=>
      return resolve [] unless host

      getBuilds = @_queryTeamCity(url: 'buildTypes', baseUrl: @_urlWithHost host)

      getBuilds.then (result)->
        builds = _.map result.buildType, (buildType)->
          Ember.Object.create _.pick buildType, 'id', 'name', 'projectId', 'projectName'
        resolve builds

      getBuilds.catch -> resolve []

  getActiveBuilds: (builds)->
    buildPromises =
      running: @_runningBuilds builds
      queued: @_queuedBuilds builds

    Ember.RSVP.hash(buildPromises).then (result)->
      _.flatten _.map result.running, (buildType)->
        _.map buildType.builds, (activeBuild)->
          parentBuild = _.find builds, (build)->
            build.id is activeBuild.buildTypeId

          status = if _.contains(result.queued, activeBuild.buildTypeId) and not activeBuild.running
            'queued'
          else
            activeBuild.status.toLowerCase()

          Ember.Object.create
            id: activeBuild.id
            running: !!activeBuild.running
            percentageComplete: activeBuild.percentageComplete
            branchName: (activeBuild.branchName || buildType.name).replace 'refs/heads/', ''
            status: status
            order: parentBuild.order

  _urlWithHost: (host)->
    "http://#{host}/guestAuth/app/rest/"

  _queryTeamCity: (options = {})->
    options = _.defaults options, baseUrl: @get('baseUrl'), locator: ''
    locator = options.locator and "?locator=#{@_serializeLocator options.locator}"
    new Ember.RSVP.Promise (resolve, reject)=>
      $.getJSON "#{options.baseUrl}#{options.url}#{locator}"
        .then (value)-> resolve value
        .fail (error)-> reject error

  _serializeLocator: (locator)->
    _.map(locator, (value, key)-> "#{key}:#{value}").join(',')

  _runningBuilds: (builds)->
    running = _.map builds, (build)=>
      locator =
        running: 'any'
        branch: 'branched:any'
        buildType: build.id
        sinceDate: moment().subtract('days', 1).format 'YYYYMMDDTHHmmssZZ'

      @_queryTeamCity(url: 'builds', locator: locator).then (data)=>
        uniqueBuilds = _.uniq data.build, (build)-> build.branchName

        name: build.name
        builds: _.filter uniqueBuilds, (build)->
          build.status isnt 'UNKNOWN' and build.branchName isnt '<default>'

    Ember.RSVP.all running

  _queuedBuilds: (builds)->
    queued = _.map builds, (build)=>
      @_queryTeamCity(url: 'buildQueue', locator: buildType: build.id).then (data)->
        return null unless data.count
        _.pluck data.build, 'buildTypeId'

    Ember.RSVP.all(queued).then (result)->
      _.flatten _.compact result

App.teamCity = TeamCity.create()
