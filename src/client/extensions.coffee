m     = require 'mithril'

pubs  = "update destroy create sync".split(' ')

exports.wrap = (Mithink)->

  Mithink.__tables__ = {}

  Mithink.lastError  = m.prop({})

  Mithink._table = (name)->
    Mithink.__tables__[name]

  Mithink.table = (name)->
    return Mithink._table(name) if Mithink._table(name)
    table          = Mithink.__tables__[name] = Mithink.adapter.Table.create()
    table.name     = name
    table.Row      = Mithink.adapter.Row
    table.channel  = Mithink.createConnection(name)
    table._loading = true

    table.channel.on 'http_error', (err)->
      Mithink.lastError(err)
      table._loading = false if table._loading
      # resync errored data
      table.sync(err.data) if err.data && err.data.id
      Mithink.errorHandler(err) if Mithink.errorHandler

    for action, handler of Mithink.adapter.Table.handlers
      do (action, handler)->
        #console.log "registering handler: #{action}"
        table.channel.on action, (data)->
          #console.log "activating handler: #{action}"
          handler.call(table, data)
          Mithink.redraw() if Mithink.redraw

    for action in pubs
      do (action)->
        table[action] = (data)->
          table.channel.emit action, data
          return table

    table.load = (params)->
      return table if table._loading
      if params || table.length() is 0
        table._loading = true
        table.channel.emit "load", params
      return table

    table
