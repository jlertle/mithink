exports.init = ->
  Adapter       = {}
  Adapter.Table = require('./Table')
  Adapter.Row   = require('./Row')
  Adapter