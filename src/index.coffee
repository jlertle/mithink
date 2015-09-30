###*
# @title Universal detection
# @text here we detect if we are on the server or the client
###

module.exports = if typeof window isnt 'undefined' then require('./client') else require('./server')