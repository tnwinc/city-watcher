Ember = require 'ember'
App = require '../app'
_ = require 'lodash'

require './controller'
require './view'
require './configure'

App.ConfigureRoute = Ember.Route.extend

  setupController: (controller)->
    host = @store.fetch 'host'
    controller.set 'host', host

    selectedBuilds = _.map @store.fetch('builds') or [], (selectedBuild)->
      Ember.Object.create selectedBuild
    sortableSelectedBuilds = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      content: selectedBuilds
      sortProperties: ['order']
    controller.set 'selectedBuilds', sortableSelectedBuilds

    @teamcity.getAllBuilds(host).then (builds)->
      controller.set 'builds', builds
