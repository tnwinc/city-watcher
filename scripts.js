(function() {
  var allBuildTypes, branchBuildTemplate, branchListSource, buildType, createBuildList, hash, runFixtureMode, server, serverListSource, serverListTemplate, serversToMonitor, threeDaysAgo, updateServerList, _i, _j, _len, _len1, _ref;

  hash = window.location.hash;

  if (hash) {
    serversToMonitor = JSON.parse(hash.slice(1));
    serverListSource = $('#serverList').html();
    serverListTemplate = Handlebars.compile(serverListSource);
    branchListSource = $('#branchBuildList').html();
    branchBuildTemplate = Handlebars.compile(branchListSource);
    threeDaysAgo = moment().subtract('days', 3).format('YYYYMMDDTHHmmssZZ');
    allBuildTypes = {};
    for (_i = 0, _len = serversToMonitor.length; _i < _len; _i++) {
      server = serversToMonitor[_i];
      _ref = server.buildTypes;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        buildType = _ref[_j];
        allBuildTypes[buildType] = {
          urlForRunningBuilds: "" + server.protocol + "://" + server.address + "/app/rest/builds?locator=running:all,branch:branched:any,buildType:" + buildType + ",sinceDate:" + threeDaysAgo,
          urlForSpecificBuild: "" + server.protocol + "://" + server.address + "/app/rest/builds/id:",
          name: "master-" + buildType
        };
      }
    }
  }

  createBuildList = function() {
    var buildConfigurations, html, serversProjection;

    serversProjection = (function() {
      var _k, _len2, _results;

      _results = [];
      for (_k = 0, _len2 = serversToMonitor.length; _k < _len2; _k++) {
        server = serversToMonitor[_k];
        buildConfigurations = (function() {
          var _l, _len3, _ref1, _results1;

          _ref1 = server.buildTypes;
          _results1 = [];
          for (_l = 0, _len3 = _ref1.length; _l < _len3; _l++) {
            buildType = _ref1[_l];
            $.getJSON("" + server.protocol + "://" + server.address + "/app/rest/buildTypes/id:" + buildType, function(data) {
              var buildTypeToUpdate;

              $("#" + data.id + " h2").text(data.name);
              buildTypeToUpdate = allBuildTypes[data.id];
              return allBuildTypes[data.id] = {
                urlForRunningBuilds: buildTypeToUpdate.urlForRunningBuilds,
                urlForSpecificBuild: buildTypeToUpdate.urlForSpecificBuild,
                name: data.name
              };
            });
            _results1.push({
              id: buildType,
              name: buildType
            });
          }
          return _results1;
        })();
        _results.push({
          friendlyName: server.friendlyName,
          buildConfigurations: buildConfigurations
        });
      }
      return _results;
    })();
    html = serverListTemplate({
      servers: serversProjection
    });
    return document.body.innerHTML = html;
  };

  updateServerList = function() {
    var buildTypeId, _results;

    _results = [];
    for (buildTypeId in allBuildTypes) {
      buildType = allBuildTypes[buildTypeId];
      _results.push((function(buildTypeId, buildType) {
        return $.getJSON(buildType.urlForRunningBuilds, function(data) {
          var O_o, branchName, build, buildInfo, buildKey, buildProjection, builds, running, _k, _len2, _ref1;

          builds = {};
          if (data.count > 0) {
            _ref1 = data.build;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              build = _ref1[_k];
              buildKey = build.branchName || buildTypeId;
              if (builds[buildKey] == null) {
                builds[buildKey] = {
                  buildType: buildType,
                  build: build
                };
              }
            }
            buildProjection = (function() {
              var _results1;

              _results1 = [];
              for (O_o in builds) {
                buildInfo = builds[O_o];
                running = buildInfo.build.running;
                branchName = (buildInfo.build.branchName == null) || buildInfo.build.branchName === "refs/heads/master" ? buildType.name : buildInfo.build.branchName;
                if (running) {
                  (function(buildType, branchName) {
                    return $.getJSON(buildType.urlForSpecificBuild + buildInfo.build.id, function(data) {
                      $("#" + buildTypeId + " .branch-name-" + branchName + " .status-text").text(data.statusText);
                      return $("#" + buildTypeId + " .branch-name-" + branchName + " .stage-text").text(data["running-info"].currentStageText);
                    });
                  })(buildType, branchName);
                }
                _results1.push({
                  status: buildInfo.build.status.toLowerCase(),
                  name: branchName,
                  percentageComplete: buildInfo.build.percentageComplete || (running ? 0 : 100),
                  running: running ? "running" : "not-running"
                });
              }
              return _results1;
            })();
          } else {
            buildProjection = [
              {
                status: "no-recent-builds",
                name: "" + (buildType.name || buildTypeId) + " - No Recent Builds",
                percentageComplete: 100,
                running: false
              }
            ];
          }
          return $("#" + buildTypeId + " ul").html(branchBuildTemplate({
            builds: buildProjection
          }));
        });
      })(buildTypeId, buildType));
    }
    return _results;
  };

  runFixtureMode = function() {
    var runningDiv;

    $('#fixtures').show();
    runningDiv = $('.running .branch');
    return setInterval(function() {
      return runningDiv.each(function() {
        var $this, widthPercentage;

        $this = $(this);
        widthPercentage = parseInt($this.data('widthPercentage')) || 10;
        if (widthPercentage === 100) {
          widthPercentage = 0;
        } else {
          widthPercentage = widthPercentage += Math.floor(Math.random() * 20);
          if (widthPercentage > 100) {
            widthPercentage = 100;
          }
        }
        return $this.data('widthPercentage', widthPercentage).css({
          width: "" + widthPercentage + "%"
        });
      });
    }, 1500);
  };

  $(function() {
    if (hash) {
      createBuildList();
      updateServerList();
      return setInterval(updateServerList, 5000);
    } else {
      return runFixtureMode();
    }
  });

}).call(this);
