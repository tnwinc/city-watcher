Ember = require 'ember'

App = Ember.Application.create()

idMatch = location.search.match /\?.*id\=(\d+)/
id = if idMatch then "-#{idMatch[1]}" else ''

App.VERSION = '0.2.0'
App.NAMESPACE = "city-watcher#{id}"

module.exports = App
