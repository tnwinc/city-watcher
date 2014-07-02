App = require '../app'
BaseRoute = require '../shared/base_route'

App.IndexRoute = BaseRoute.extend

  redirect: ->
    @transitionTo 'builds'
