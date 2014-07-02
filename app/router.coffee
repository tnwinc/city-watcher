App = require './app'

require './services/store'
require './services/teamcity'

require './components/progress_bar_component'
require './components/components.progress-bar'
require './components/sortable_list_component'
require './components/components.sortable-list'

require './index/route'
require './builds/route'
require './configure/route'

App.Router.map ->
  @route 'configure'
  @resource 'builds'
