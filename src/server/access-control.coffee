utils = require '../utils'
debug = require('debug')("mithink:security")
log   = require('debug')('mithink:actions')

errorHandler = require './error-handler'

Access_Control = (Bus)->
  # store for our access control functions
  Bus.__access_control__ = {}

  ###*
  # defines access control middleware for actions
  # @class Server.Model 
  # @function Server.Model#guard
  # @param {Object} opts - an Object of actions to protect, and how to protect them
  # @example
  # Thing.guard {
  #   connection: (socket)->
  #     return false unless socket.authenticated
  #     return true
  # }
  ###
  Bus.guard  = (opts)->
    for action, check of opts
      Bus.__access_control__[ utils.namespace(@model._name, action) ] = check

  # getter for an access control middleware
  Bus.checkpoint = ->
    Bus.__access_control__[ utils.namespace(@model._name, @action) ] || utils.allowAll

  # called before an action is initialized
  Bus.__protect__ = (action)->
    # outer context
    ctx = @

    # action wrapped by check
    return (args...)->
      passed  = Bus.checkpoint.call(ctx)(ctx.socket)
      denyMessage = "unauthorized attempt to perform #{ctx.action} on #{ctx.model._name} table"
      
      if passed.then
        return passed
          .then ()->
            log "#{ctx.socket.id} performing #{ctx.action.toUpperCase()} on #{ctx.model._name.toUpperCase()} -- params: #{JSON.stringify(utils.redact args)}"
            action.apply(ctx, args)
          .catch (err={})-> 
            debug(err.message || denyMessage)
            errorHandler.call(ctx, 401, args[0], message: err.message || denyMessage)

      if passed

        log "#{ctx.socket.id} performing #{ctx.action.toUpperCase()} on #{ctx.model._name.toUpperCase()} -- params: #{JSON.stringify( utils.redact args)}"
        return action.apply(ctx, args) 
      
      debug(denyMessage)
      return errorHandler.call(ctx, 401, args[0], message: denyMessage)


module.exports = Access_Control  