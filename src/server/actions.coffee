debug = require('debug')('mithink:actions')
errorHandler = require './error-handler'

exports.load = (params = {})->
  @model.filter(params).then (data)=>
    @socket.emit "load", data

exports.update = (data)->
  @model.save(data, { conflict: "update" }).catch errorHandler.bind(@, 400, data)

exports.destroy = (data)->
  @model
    .get(data.id)
    .then (instance)=>
      instance
        .delete()
        .catch errorHandler.bind(@, 400, data)

    .catch errorHandler.bind(@, 400, data)

exports.create = (data)->
  instance = new @model(data)

  instance.save(data).catch errorHandler.bind(@, 400, data)

exports.sync = (data)->
  @model.get(data.id)
    .then @socket.emit.bind @socket, 'sync'
    .catch errorHandler.bind(@, 400, data)
