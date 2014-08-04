Ember = require 'ember'
App = require '../app'
Migrator = require '../services/migrator/migrator'

App.ApplicationRoute = Ember.Route.extend

  beforeModel: ->
    Migrator.create(store: @store).runMigrations()
