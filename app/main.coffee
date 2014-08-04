App = require './app'

require './services/services'
require './components/components'

require './application/route'
require './index/route'
require './builds/route'
require './configure/route'

App.Router.map ->
  @route 'configure'
  @resource 'builds'
