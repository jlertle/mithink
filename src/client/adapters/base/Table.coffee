m = require 'mithril'

### 
# @title Client - Table
# @class Table
# @overview Base class to inherit from to make writing an adapter easier
###

module.exports = class Table
  
  @Row: require('./Row')

  @create : (rows=[])->
    new @(rows)

  constructor: (rows=[])->
    @_loading = false
    @

  finishLoading: ->
    @_loading = false
    @

  isLoading: ->
    return @_loading || false

  rows: (rowsToAdd)->
    # stub

  remove: (query)->
    # stub

  add: (adding)->
    # stub

  reset: (rows)->
    # stub

  get: (id)->
    # stub

  all : ->
    # stub

  at: (index)->
    # stub

  length: ->
    # stub

  toJSON: ->
    # stub

  on: (evt, handler)->
    @channel.on(evt, handler)
    @

  once: (evt, handler)->
    @channel.once(evt, handler)
    @

  emit: (evt, data)->
    @channel.emit(evt, data)
    @

Table.handlers =
    load: (data)->
      throw new Error "your adapter should override Table.handlers.load"

    upsert: (doc)->
      throw new Error "your adapter should override Table.handlers.upsert"

    destroy: (doc)->
      throw new Error "your adapter should override Table.handlers.destroy"

    sync: (doc)->
      throw new Error "your adapter should override Table.handlers.sync"
