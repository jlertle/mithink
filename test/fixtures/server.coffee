mithink = require('../../src')()

app     = require('http').createServer()
io      = require('socket.io')(app)

mithink.bus(io)

models = {
  Thing: require('./models/Thing')(mithink)
}

module.exports = {
  io      : io
  models  : models
  mithink : mithink
}