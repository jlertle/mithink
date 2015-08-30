m = require 'mithril'

module.exports = class Table
  Row : require('./Row')

  @create : (rows=[])->
    new @(rows)

  constructor: (rows=[])->
    @rows = m.prop rows.map @_rowize.bind(@)
    @_loading = false
    @

  finishLoading: ->
    @_loading = false
    @

  _rowize: (attrs)->
    row       = new @Row(attrs)
    row.table = @
    row

  sortBy: (sort)->
    key = Object.keys(sort)[0]
    mod = sort[key]

    @rows Array.prototype.sort.call @rows(), (a, b)->
      weight = a.get(key) - b.get(key)
      return -1 * weight if mod is -1
      return weight
    @

  isLoading: ->
    return @_loading || false

  map: (fn)->
    Array.prototype.map.call @rows(), fn

  where: (query)->
    @filter (m)->
      state = false
      for attr in Object.keys(query)
        state = m.has(attr) and m.attributes[attr]() is query[attr]
      state

  first: (query)->
    return @where(query)[0] || null if query
    return @at(0)

  filter: (fn)->
    Array.prototype.filter.call @rows(), fn

  remove: (query)->
    @rows @filter (m)->
      state = false
      for attr in Object.keys(query)
        state = m.has(attr) and m.attributes[attr]() isnt query[attr]
      state

  add: (adding)->
    return @rows @rows().concat [adding] if adding instanceof @Row

    return @rows @rows().concat [new @Row adding] unless Array.isArray(adding)

    @rows @rows().concat adding.map (row)=>
      return row if row instanceof @row
      return new @Row row

  reset: (rows)->
    @rows rows.map @_rowize.bind(@)
    @

  get: (id)->
    @first id: id

  all : ->
    @rows()

  at: (index)->
    @rows()[index]

  length: ->
    @rows().length

  toJSON: ->
    @map (row)->
      row.toJSON()

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

    remove: (doc)->
      @rows @filter (row)->
        row.get('id') isnt doc.id
      @

    sync: (doc)->
      @first(id: doc.id).set(doc)
      @
