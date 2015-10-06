Mithril    = require('./adapters/mithril')
extensions = require('./extensions')

Mithink = (host, adapter)->
  return Mithink if Mithink.socket
  Mithink.adapter = adapter || Mithril.init()
  Mithink.host    = host    || window.location.origin
  Mithink.socket  = Mithink.createConnection()
  Mithink

extensions.wrap Mithink

Mithink.createConnection = (channel)->
  location = [ Mithink.host ]
  location.push channel if channel
  return io location.join('/')

module.exports = Mithink