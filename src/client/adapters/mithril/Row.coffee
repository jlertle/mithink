m = require 'mithril'

module.exports = class Row
  @create : (attrs)->
    new @(attrs)

  constructor: (attrs)->
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

  has: (attr)->
    if @attributes[attr] then true else false

  get: (attr)->
    return null unless @has attr
    @attributes[attr]()

  toJSON: ->
    j = {}
    j[attr] = @get(attr) for attr, prop of @attributes
    j