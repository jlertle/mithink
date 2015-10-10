utils = {}

utils.LENGTH_MSG       = "{{ REDACTED [length] }}"
utils.SENSITIVE_MSG    = "{{ REDACTED [sensitive] }}"
utils.MAX_LENGTH = 150

utils.redact = (args)->
  return args if args.length is 0
  args.map (arg)->
    return arg unless arg
    if typeof arg.length && arg.length > utils.MAX_LENGTH
      return utils.LENGTH_MSG
    if typeof arg is 'object'
      return utils.redactObject(arg)

    return arg

utils.redactObject = (obj)->
  n = {}
  
  for k, v of obj
    if k is 'password'
      n[k] = utils.SENSITIVE_MSG
    # Buffer typeofs to 'object' so we should check for length first
    else if v.length && v.length > utils.MAX_LENGTH
      n[k] = utils.LENGTH_MSG
    else if typeof v is 'object'
      n[k] = utils.redactObject(v)
    else
      n[k] = v
  n

module.exports = utils.redact