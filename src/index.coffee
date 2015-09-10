# # Mithink
# detect if we are in the browser or on the server and require the appropriate logic

module.exports = if typeof window isnt 'undefined' then require('./client') else require('./server')