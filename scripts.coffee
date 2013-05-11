hash = window.location.hash

if hash

  serversToMonitor = JSON.parse hash[1..]
  serverListSource = $('#serverList').html()
  serverListTemplate = Handlebars.compile serverListSource

  branchListSource = $('#branchBuildList').html()
  branchBuildTemplate = Handlebars.compile branchListSource

  threeDaysAgo = moment().subtract('days', 3).format('YYYYMMDDTHHmmssZZ')

  allBuildTypes = {}

  for server in serversToMonitor
    for buildType in server.buildTypes
      allBuildTypes[buildType] =
      {
        urlForRunningBuilds: "#{server.protocol}://#{server.address}/app/rest/builds?locator=running:all,branch:branched:any,buildType:#{buildType},sinceDate:#{threeDaysAgo}",
        urlForSpecificBuild: "#{server.protocol}://#{server.address}/app/rest/builds/id:",
        name: "master-#{buildType}"
      }

createBuildList = ->
  serversProjection = for server in serversToMonitor
    buildConfigurations = for buildType in server.buildTypes
      $.getJSON "#{server.protocol}://#{server.address}/app/rest/buildTypes/id:#{buildType}", (data) ->
        $("##{data.id} h2").text data.name
        buildTypeToUpdate = allBuildTypes[data.id]
        allBuildTypes[data.id] = { urlForRunningBuilds: buildTypeToUpdate.urlForRunningBuilds, urlForSpecificBuild: buildTypeToUpdate.urlForSpecificBuild, name: data.name }
      {
        id: buildType,
        name: buildType
      }

    {
      friendlyName: server.friendlyName,
      buildConfigurations: buildConfigurations
    }

  html = serverListTemplate {servers: serversProjection}

  document.body.innerHTML = html

updateServerList = ->
  for buildTypeId, buildType of allBuildTypes
    do (buildTypeId, buildType)->
      $.getJSON buildType.urlForRunningBuilds, (data)->
        builds = {}

        if data.count > 0
          for build in data.build
            buildKey = build.branchName or buildTypeId
            if not builds[buildKey]? and build.status != "UNKNOWN"
              builds[buildKey] = { buildType: buildType, build: build }

          buildProjection = for O_o, buildInfo of builds
            running = buildInfo.build.running
            id = buildTypeId + buildInfo.build.branchName.replace /\//g, ''
            branchName = if not buildInfo.build.branchName? or buildInfo.build.branchName == "refs/heads/master" then buildType.name else buildInfo.build.branchName

            if running
              do (buildType, branchName)->
                $.getJSON buildType.urlForSpecificBuild + buildInfo.build.id, (data)->
                  $("##{buildTypeId} .branch-name-#{branchName} .status-text").text data.statusText
                  $("##{buildTypeId} .branch-name-#{branchName} .stage-text").text data["running-info"].currentStageText
            {
              id: id
              buildTypeId: buildTypeId
              status: buildInfo.build.status.toLowerCase()
              name: branchName
              percentageComplete: buildInfo.build.percentageComplete or (if running then 0 else 100)
              running: if running then "running" else "not-running"
            }
        else
          buildProjection =
          [{
              id: buildTypeId + "refsheadsmaster"
              buildTypeId: buildTypeId
              status: "no-recent-builds"
              name: "#{buildType.name or buildTypeId} - No Recent Builds"
              percentageComplete: 100
              running: "not-running"
          }]

        for build in buildProjection
          if not $("##{build.id}").length
            $("##{buildTypeId} ul").append branchBuildTemplate {builds: buildProjection}
          li = $("##{build.buildTypeId} ul li.branch-name-#{build.name}")

          statuses = ['failure', 'success', 'no-recent-builds']
          li.addClass "status-#{build.status}"
          li.removeClass status for status in statuses when status != build.status

          if build.running == "running"
            li
              .removeClass('not-running')
              .addClass('running')

            li.find(".branch")
              .width("#{build.percentageComplete - 20}%")
          else
            li.removeClass('running').addClass('not-running')


runFixtureMode = ->
  $('#fixtures').show()
  runningDiv = $('.running .branch')
  setInterval ->
    runningDiv.each ->
      $this = $(this)
      widthPercentage = parseInt($this.data 'widthPercentage') or 10
      if widthPercentage is 100
        widthPercentage = 0
      else
        widthPercentage = widthPercentage += Math.floor(Math.random() * 20)
        if widthPercentage > 100
          widthPercentage = 100

      $this
        .data('widthPercentage', widthPercentage)
        .css width: "#{widthPercentage}%"
  , 1500

$ ->
  if hash
    createBuildList()
    updateServerList()
    setInterval(updateServerList, 5000)
  else
    runFixtureMode()
