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
  model.guard    = Bus.guard.bind { model: model }
  model.channel  = Bus.io.of utils.channelName model._name
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
  ctx.action = 'load'
  Bus.__protect__.call(ctx, Bus.action('load'))()

  for action, handler of Bus.__actions__
    do (action, handler)->
      instance = utils.shallowCopy(ctx)
      instance.action = action
      socket.on action, Bus.__protect__.call(instance, handler)
    

Bus.registerActions = (opts)->
  Bus.__actions__[action] = fn for action, fn of opts
  Bus

Bus.registerActions require('./actions')

Bus.action = (action)->
  Bus.__actions__[action]

###
# If you pass in an Object of Thinky models handle it
# 
###

Bus.registerModels = (modelorModelsObj)->
  
  if utils.isPlainObject(modelorModelsObj)
    Bus.extend(model).wireUp(model) for namespace, model of modelorModelsObj
    return Bus

  if Array.isArray(modelorModelsObj)
    Bus.extend(model).wireUp(model) for model in modelorModelsObj
    return Bus
  
  Bus.extend(model).wireUp(model)

  Bus

module.exports = Bus