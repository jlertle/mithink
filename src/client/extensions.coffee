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
    table.channel  = Mithink.createConnection(name)
    table._loading = true
    
    table.channel.on 'http_error', (err)-> 
      Mithink.lastError(err)
      table._loading = false if table._loading
      # resync errored data
      table.sync(err.data)
      Mithink.errorHandler(err) if Mithink.errorHandler

    for action, handler of Mithink.adapter.Table.handlers
      do (action, handler)->
        table.channel.on action, (data)->
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
