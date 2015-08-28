debug = require('debug')('mithink:actions')

exports.load = ->
  debug "loading #{@model._name} table"
  @model.run().then (data)=>
    @socket.emit "load", data

exports.update = (data)->
  debug "updating #{data.id}"
  debug data
  @model.save(data, { conflict: "update" }).catch (err)=>
    
    @socket.emit "http_error", {
      code    : 404
      message : err.message
      table   : @table
      action  : @action
    }

exports.destroy = (data)->

exports.create = (data)->