window.App = Ember.Application.create()

idMatch = location.search.match /\?.*id\=(\d+)/
id = if idMatch then "-#{idMatch[1]}" else ''

App.NAMESPACE = "city-watcher#{id}"
