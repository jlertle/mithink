utils = require '../utils'

Access_Control = (Bus)->
  # store for our access control functions
  Bus.__access_control__ = {}

  # definite access control middleware for actions
  Bus.guard  = (opts)->
    for action, check in Object.keys(opts)
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
      
      if checkpoint = Bus.checkpoint.call(ctx) && not checkpoint(@socket)
        
        debug "unauthorized attempt to perform #{ctx.action} on the #{ctx.model._name} table"

        return ctx.socket.emit "http_error", {
          code    : 403
          message : "unauthorized attempt to perform #{ctx.action} on the #{ctx.model._name} table"
          table   : ctx.model._name
          action  : ctx.action
        }

      action.apply(ctx, args)


module.exports = Access_Control
  