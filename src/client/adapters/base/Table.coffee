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
      @_loading = false
      @_errored = false
      @reset(data)
      @

    upsert: (doc)->
      update = @first id: doc.id

      if update
        update.set(doc)
      else
        @add doc
      @

    delete: (doc)->
      @rows @filter (row)->
        row.get('id') isnt doc.id
      @

    sync: (doc)->
      @first(id: doc.id).set(doc)
      @
