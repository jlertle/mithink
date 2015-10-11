m = require 'mithril'

module.exports = class Mithril_Row
  @create : (attrs, table)->
    new @(attrs, table)

  constructor: (attrs, @table)->
    @set(@defaults) if @defaults
    @set(attrs)

  set: (args...)->
    @attributes = {} unless @attributes
    
    # if was name, val prepare for iteration
    if args.length is 2
      attrs = {}
      attrs[args[0]] = args[1]
    # if was object of attributes prepare for iteration
    else
      attrs = args[0]

    for attr, v of attrs
      if @has(attr)
        @attributes[attr](v)
      else
        @attributes[attr] = m.prop(v)
    @

  save: ->
    @table.update @toJSON()

  has: (attr)->
    if @attributes[attr] && @attributes[attr]() isnt null then true else false

  get: (attr)->
    return null unless @has attr
    @attributes[attr]()

  toJSON: ->
    j = {}
    for attr, prop of @attributes
      val = @get(attr)
      if val.toJSON
        val = val.toJSON()
      if Array.isArray(val)
        val = val.map (ele)->
          return ele unless ele.toJSON
          ele.toJSON()
      j[attr] = val
    j