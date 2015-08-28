exports.channelName = (str)->
  "/" + str

exports.namespace = (args...)->
  args.join(':')

exports.isPlainObject = (obj)->
  Object.prototype.toString.call(obj) is '[object Object]'