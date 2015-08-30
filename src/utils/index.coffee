exports.channelName = (str)->
  "/" + str

exports.namespace = (args...)->
  args.join(':')

exports.isPlainObject = (obj)->
  Object.prototype.toString.call(obj) is '[object Object]'

exports.shallowCopy = (obj)->
  n = {}
  n[key] = val for key, val of obj
  n

exports.keys = (obj)->
  keys = []
  keys.push(key) for key, val of obj
  keys

exports.merge = (objs...)->
  memo = {}
  for obj in objs
    memo[key] = val for key, val of obj
  memo
  