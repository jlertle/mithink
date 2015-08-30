utils = require '../utils'
debug = require('debug')("mithink:security")

errorHandler = require './error-handler'

Access_Control = (Bus)->
  # store for our access control functions
  Bus.__access_control__ = {}

  # definite access control middleware for actions
  Bus.guard  = (opts)->
    for action, check of opts
      Bus.__access_control__[ utils.namespace(@model._name, action) ] = check

  # getter for an access control middleware
  Bus.checkpoint = (action)->
    Bus.__access_control__[ utils.namespace(@model._name, @action) ]

  # called before an action is initialized
  Bus.__protect__ = (action)->
    # outer context
    ctx = @

    # action wrapped by check
    return (args...)->
      checkpoint = Bus.checkpoint.call(ctx)
      if checkpoint && not checkpoint(@socket)
        msg = "unauthorized attempt to perform #{ctx.action} on the #{ctx.model._name} table"
        debug(msg)
        return errorHandler.call(ctx, 401, args[0], message: msg)

      action.apply(ctx, args)


module.exports = Access_Control
  