m = require 'mithril'

module.exports = class Row
  @create : (attrs, table)->
    new @(attrs, table)

  constructor: (attrs, table)->
    throw new Error "your adapter should overwrite the Row.constructor instance method"

  toJSON: ->
    throw new Error "your adapter should overwrite the Row.toJSON instance method"