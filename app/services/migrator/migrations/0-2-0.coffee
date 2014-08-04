Ember = require 'ember'

module.exports = Ember.Object.extend

  run: ->
    new Ember.RSVP.Promise (resolve)=>
      store = @get 'store'
      builds = store.fetch 'builds'

      runners = for build in builds
        build.type = 'build'
        build

      store.save
        builds: null
        runners: runners

      resolve()
