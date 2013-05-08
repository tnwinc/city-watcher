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
      $.getJSON "#{server.protocol}://#{server.address}/app/rest/buildTypes/id:#{buildType}", (data)->
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
            if not builds[buildKey]?
              builds[buildKey] = { buildType: buildType, build: build }

          buildProjection = for O_o, buildInfo of builds
            running = buildInfo.build.running
            branchName = if not buildInfo.build.branchName? or buildInfo.build.branchName == "refs/heads/master" then buildType.name else buildInfo.build.branchName

            if running
              do (buildType, branchName)->
                $.getJSON buildType.urlForSpecificBuild + buildInfo.build.id, (data)->
                  $("##{buildTypeId} .branch-name-#{branchName} .status-text").text data.statusText
                  $("##{buildTypeId} .branch-name-#{branchName} .stage-text").text data["running-info"].currentStageText
            {
              status: buildInfo.build.status.toLowerCase()
              name: branchName
              percentageComplete: buildInfo.build.percentageComplete or (if running then 0 else 100)
              running: if running then "running" else "not-running"
            }
        else
          buildProjection =
          [{
              status: "no-recent-builds"
              name: buildType.name or buildTypeId
              percentageComplete: 100
              running: false
          }]

        $("##{buildTypeId} ul").html branchBuildTemplate {builds: buildProjection}

runFixtureMode = ->
  $('#fixtures').show()
  runningDiv = $('.running div')
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
