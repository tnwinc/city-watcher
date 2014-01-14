hash = window.location.hash

if hash
  serversToMonitor = JSON.parse hash[1..]
  serverListSource = $('#serverList').html()
  serverListTemplate = Handlebars.compile serverListSource

  branchListSource = $('#branchBuildList').html()
  branchBuildTemplate = Handlebars.compile branchListSource

  daysToLookBack = (moment().subtract 'days', 3).format 'YYYYMMDDTHHmmssZZ'

  allBuildTypes = {}

  for server in serversToMonitor
    serverEndPoint = "#{server.protocol}://#{server.address}/guestAuth/app/rest/"
    for buildType in server.buildTypes
      server.urlForSpecificBuildType = "#{serverEndPoint}buildTypes/id:"
      allBuildTypes[buildType] =
      {
        urlForRunningBuilds: "#{serverEndPoint}builds?locator=running:all,branch:branched:any,buildType:#{buildType},sinceDate:#{daysToLookBack}"
        urlForSpecificBuild: "#{serverEndPoint}builds/id:"
        name: "master-#{buildType}"
      }

createBuildList = ->
  serversProjection = for server in serversToMonitor
    buildConfigurations = for buildType in server.buildTypes
      $.getJSON server.urlForSpecificBuildType + buildType, (data) ->
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

          buildProjection = for O_o, buildInfo of builds when buildInfo.build.branchName != '<default>'
            running = buildInfo.build.running
            branchName = (buildInfo?.build?.branchName || "master").replace('refs/heads/', '')
            id = "#{buildTypeId}-#{branchName}"
            displayName = if branchName == "master" then buildType.name else branchName

            if running
              do (id)->
                $.getJSON buildType.urlForSpecificBuild + buildInfo.build.id, (data)->
                  escapedBuildId = build.id.replace( /(:|\.|\[|\])/g, "\\$1" )
                  $("##{escapedBuildId} p.status-text").text data.statusText
                  $("##{escapedBuildId} p.stage-text").text data["running-info"].currentStageText
            {
              id: id
              buildTypeId: buildTypeId
              status: buildInfo.build.status.toLowerCase()
              name: displayName
              percentageComplete: buildInfo.build.percentageComplete or (if running then 0 else 100)
              running: if running then "running" else "not-running"
            }
        else
          buildProjection =
          [{
              id: buildTypeId + "master"
              buildTypeId: buildTypeId
              status: "no-recent-builds"
              name: "#{buildType.name or buildTypeId} - No Recent Builds"
              percentageComplete: 100
              running: "not-running"
          }]

        for build in buildProjection
          escapedBuildId = build.id.replace( /(:|\.|\[|\])/g, "\\$1" )
          buildDoesNotExist = $("##{escapedBuildId}").length < 1
          if buildDoesNotExist
            $("##{buildTypeId} ul").append branchBuildTemplate {builds: buildProjection}

          liForSpecificBuild = $("##{build.id}")

          liForSpecificBuild.find('h2').text build.name

          statuses = ['failure', 'success', 'no-recent-builds']
          liForSpecificBuild.addClass "status-#{build.status}"
          liForSpecificBuild.removeClass "status-#{status}" for status in statuses when status != build.status

          branch = liForSpecificBuild.find(".branch")

          if build.running == "running"
            liForSpecificBuild
              .removeClass('not-running')
              .addClass('running')

            branch
              .width("#{build.percentageComplete - 20}%") #NO IDEA why I have to take away 20, but I do
          else
            liForSpecificBuild.removeClass('running').addClass('not-running')
            branch.width("100%")


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
        widthPercentage = Math.min widthPercentage += Math.floor(Math.random() * 20), 100

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
