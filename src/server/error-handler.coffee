module.exports =  (code, data, err)->
  @socket.emit "http_error", {
    code    : code
    message : err.message
    raw     : err
    data    : data
    table   : @model._name
    action  : @action
  }