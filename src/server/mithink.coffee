
t   = require "thinky"
Bus = require './bus'

#  # Mithink
# a convience wrapper for [thinky](http://thinky.io/documentation/) that returns a `thinky` instance extended by `mithink`
Mithink = (args...)->
  Mithink.$     = t.apply(t, args)
  Mithink.r     = Mithink.$.r
  Mithink.type  = Mithink.$.type
  Mithink.Query = Mithink.$.Query
  Mithink.Errors= Mithink.$.Errors
  Mithink

# ## Mithink.bus
# accepts an instance of socket.io 
# we will use to bus events
Mithink.bus = (io)->
  Bus(io)
  Mithink

# ## Mithink.proxy
# `Mithink.proxy('something', arg1, arg2, ...)`
# proxies a method call to thinky, which gives you access to [these calls](http://thinky.io/documentation/api/thinky/)
Mithink.proxy = (method, args)->
  throw new Error "thinky has not been initialized, please see http://thinky.io/documentation" unless Mithink.$
  Mithink.$[method].apply(Mithink.$, args) 

# ## Mithink.createModel(name, schema, options)
# proxies a createModel call to thinky and extends the model with our extra methods
Mithink.createModel = (args...)->
  model = Mithink.proxy 'createModel', args
  Bus.extend(model).wireUp model
  model

module.exports = Mithink