m     = require 'mithril'
subs  = "load upsert remove".split(' ')
pubs  = "update destroy create".split(' ')

exports.wrap = (Mithink)->
  
  Mithink.__tables__ = {}

  Mithink._table = (name)->
    Mithink.__tables__[name]

  Mithink.table = (name)->
    return Mithink._table(name) if Mithink._table(name)
    table = Mithink.__tables__[name] = new Mithink.adapter.Table
    table.channel = Mithink.createConnection(name)
    
    for action in subs
      do (action)->
        table.channel.on action, (data)->
          table.handlers[action].call(table, data)
          Mithink.redraw() if Mithink.redraw

    for action in pubs
      do (action)->
        table[action] = (data)->
          table.channel.emit action, data

    table