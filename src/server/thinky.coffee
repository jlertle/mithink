
t   = require "thinky"
Bus = require './bus'

Thinky = (args...)->
  Thinky.$     = t.apply(t, args)
  Thinky.r     = Thinky.$.r
  Thinky.type  = Thinky.$.type
  Thinky.Query = Thinky.$.Query
  Thinky.Errors= Thinky.$.Errors
  Thinky

Thinky.Bus = Bus

Thinky.bus = (io)->
  Thinky.Bus(io)
  Thinky

    
Thinky.proxy = (method, args)->
  throw new Error "thinky has not been initialized, please see http://thinky.io/documentation" unless Thinky.$
  Thinky.$[method].apply(Thinky.$, args) 

Thinky.createModel = (args...)->
  model = Thinky.proxy 'createModel', args
  Bus.extend(model).wireUp model
  model

module.exports = Thinky