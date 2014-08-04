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

    selectedRunners = _.map @store.fetch('runners') or [], (selectedRunner)->
      Ember.Object.create selectedRunner
    sortableSelectedRunners = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      content: selectedRunners
      sortProperties: ['order']
    controller.set 'selectedRunners', sortableSelectedRunners

    @teamcity.getAllBuilds(host).then (builds)->
      controller.set 'builds', builds
