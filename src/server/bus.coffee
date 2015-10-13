thinky       = require "thinky"
debug        = require('debug')("mithink:bus")
actions      = require './actions'
utils        = require '../utils'
errorHandler = require './error-handler'
utils        = require '../utils'


Bus = (io)-> 
  Bus.io = io
  Bus

Bus.__actions__  = {}
Bus.__tables__   = []
Bus.NAMESPACE    = "mithink"

require('./access-control')(Bus)

Bus.extend = (model)->
  model.__mithink__      = actions : {}
  model.guard            = Bus.guard.bind { model: model }

  ###*
  # @class Server.Model 
  # @description The Server-side Model object
  # @property channel { Socket.IO.Channel } The socket.io channel for a given model
  # @example
  #   Thing = mithink.createModel 'Thing', schema, options
  ###

  model.channel = Bus.io.of utils.channelName model._name

  ###*
  # add custom events to a channel so that they can have access control handlers
  # @class Server.Model 
  # @function Server.Model#registerActions
  # @param {Object} actions - set of actions and handlers to register, will over-write preexisting handlers
  # @example
  # Thing.registerActions {
  #   mapreduce: (data)->
  #     return false unless socket.authenticated
  #     Thing.map(m).reduce(r).exec().then (data)=>
  #       # send data back to client that asked for it on the channel the event was received on
  #       this.socket.emit "mapreduce", data
  # }
  ###

  model.registerActions  = Bus._actionable_.bind(model.__mithink__)

  # intialize our baseline actions
  model.registerActions(actions)

  model.channel.on "connection", Bus.wrap.bind { model: model }

  Bus

# don't wireUp a model more than once
Bus.wireUp = (model)->
  return Bus if ~Bus.__tables__.indexOf(model._name)
  Bus.__tables__.push(model._name) 

  model.changes().then (feed)->
    feed.each (err, doc)->
      if err
        debug(err)
        throw err
      
      # deleted
      unless doc.isSaved()
        debug "emitting destroy... #{JSON.stringify( utils.redact doc )}"
        return model.channel.emit 'destroy', doc 

      # created or saved
      debug "emitting upsert... #{JSON.stringify( utils.redact doc )}"
      return model.channel.emit 'upsert', doc

  Bus


Bus.wrap = (socket)->
  # generate the context that the client events will be bound to in this channel
  
  ctx = {
    socket : socket
    model  : @model
  }

  # protect joining a channel
  do Bus.__protect__.call utils.merge( ctx, action: 'connection' ), ->

    # protect the load event of the channel
    do Bus.__protect__.call( utils.merge(ctx, action: 'load' ), @model.__mithink__.actions.load  )

    for action, handler of @model.__mithink__.actions
      do (action, handler)->
        socket.on action, Bus.__protect__.call( utils.merge(ctx, action: action), handler )

Bus._actionable_ = (opts = {})->
  @actions[action] = handler for action, handler of opts

module.exports = Bus