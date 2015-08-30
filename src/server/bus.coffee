thinky  = require "thinky"

debug   = require('debug')("mithink:bus")
actions = require './actions'
utils   = require '../utils'

Bus = (io)-> 
  Bus.io = io
  Bus

Bus.__actions__  = {}
Bus.__tables__   = []
Bus.NAMESPACE    = "methink"

require('./access-control')(Bus)

Bus.extend = (model)->
  model.__mithink__= actions : {}

  model.guard           = Bus.guard.bind { model: model }
  
  model.registerActions  = (opts={})->
    for action, handler of opts
      model.__mithink__.actions[action] = handler


  model.registerActions(actions)

  model.channel         = Bus.io.of utils.channelName model._name
  model.channel.on "connection", Bus.wrap.bind { model: model }
  Bus

Bus.wireUp = (model)->

  Bus.__tables__.push(model._name) unless ~Bus.__tables__.indexOf(model._name)

  model.changes().then (feed)->
    feed.each (err, doc)->
      if err
        debug(err)
        throw err
      
      # deleted
      unless doc.isSaved()
        debug "emitting delete..."
        return model.channel.emit 'delete', doc 

      # created or saved
      debug "emitting upsert..."
      return model.channel.emit 'upsert', doc

  Bus


Bus.wrap = (socket)->
  debug "#{socket.id} joining #{@model._name}"
  
  # generate the context that the client events will be bound to in this channel
  ctx = {
    socket : socket
    model  : @model
  }
  
  # protect loading the channel
  Bus.__protect__.call( utils.merge(ctx, action: 'load' ), @model.__mithink__.actions.load  )()

  for action, handler of @model.__mithink__.actions
    do (action, handler)->
      socket.on action, Bus.__protect__.call( utils.merge(ctx, action: action), handler )

Bus.action = (action)->
  Bus.__actions__[action]

module.exports = Bus