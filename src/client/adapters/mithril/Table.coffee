m = require 'mithril'
BaseTable = require '../base/Table'

module.exports = class Mithril_Table extends BaseTable
  @Row : require './Row'

  @create : (rows=[])->
    new @(rows)

  constructor: (rows=[])->
    @_rows    = rows.map (row)=> Mithril_Table.Row.create(row, @)
    super

  rows: (rowsToAdd)->
    return @_rows unless rowsToAdd
    @add(rowsToAdd)
    @

  map: (fn)->
    Array.prototype.map.call @all(), fn

  filter: (fn)->
    Array.prototype.filter.call @all(), fn

  where: (query)->
    @filter (m)->
      state = false
      for attr in Object.keys(query)
        state = m.has(attr) and m.attributes[attr]() is query[attr]
      state

  first: (query)->
    return @where(query)[0] || null if query
    return @at(0)

  remove: (query)->
    @rows @filter (m)->
      state = false
      for attr in Object.keys(query)
        state = m.has(attr) and m.attributes[attr]() isnt query[attr]
      state

  add: (adding)->
    if adding instanceof Mithril_Table.Row
      @_rows = @rows().concat [adding]
      return @

    unless Array.isArray(adding)
      @_rows = @rows().concat [Mithril_Table.Row.create adding] 
      return @

    @_rows = @rows().concat adding.map (row)=>
      return row if row instanceof Mithril_Table.Row
      return Mithril_Table.Row.create row, @

    return @

  reset: (rows)->
    @rows rows.map (row)=> Mithril_Table.Row.create(row, @)
    @

  get: (id)->
    @first id: id

  all: ->
    @rows()

  at: (index)->
    @rows()[index]

  length: ->
    @rows().length

Mithril_Table.handlers =
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

  destroy: (doc)->
    @rows @filter (row)->
      row.get('id') isnt doc.id
    @

  sync: (doc)->
    @first(id: doc.id).set(doc)
    @