# Mithink

`npm install mithink --save`

A plug-n-play module which aims for Meteor.js like capabilities without the overhead for transparently syncing a RethinkDB instance across clients.  Supports [Mithril.js](http://mithril.js.org/) on the client-side out of the box, but it's easy enough to roll your own adapter for Angular/Ember/Vue/whatever the hot framework of the week is.

### Under The Hood

> server

On the server `mithink` uses the excellent [thinky](http://thinky.io/documentation/) module for interaction with RethinkDB.  It should always have the [same API with a few additions](https://github.com/ondreian/mithink/blob/master/src/server/thinky.coffee) to add functionality, rather than replicating it.  We are using socket.io rooms to separate table events from the global event space.

Example usage:
```coffeescript

rethinkdb = require("mithink")(config.dev)
io        = require('socket.io')

# set up the event bus
rethinkdb.bus(io)

Thing = rethinkdb.createModel "Thing", {
  name   : rethinkdb.type.string()
  id     : rethinkdb.type.number()
  active : rethinkdb.type.boolean()
}

Thing.guard
  load: (socket)->
    return true if socket.session.authenticated
    return false

  update: (socket)->
    return true if socket.session.isAdmin
    return false

  mapreduce: (socket)->
    return true is socket.session.whatever
    return false

# the socket.io channel for Things
Thing.registerActions
  mapreduce: (data)->
    # a special query
    @socket.emit "reduction", fancyData

  # override default action
  load: (data)->
    # context includes:
    # @model  { the model of the current context }
    # @socket { the socket that emitted the event }
```

> client

On the client `mithink` caches the synced data in memory after connection and loading using socket.io in the background.  You must include socket.io in your webapp, as `mithink` makes no assumptions about the version you want to use or how you want to deliver it to the client.


example usage:

```coffeescript
# connect to socket.io
r = require('mithink')()

# for no conflict & sharing the same rendering engine  
# otherwise mithink cannot redraw diff changes from the server in the background.  
# you can set this to your own redrawing function if needed
r.redraw = m.redraw

# what to do when an "http_error" event occurs in the background
r.errorHandler = (err)->
  m.route "/error"

# a normal mithril controller/view module
Things =
  controller: ->
    # ask mithink to lazy load the Things table
    @list   = r.table("Things").load()

    @update = (evt)->
      r.table("Things").update @set('name', evt.target.value)
    return @

  view: (ctrl)->
    return m 'h1', 'loading...' if ctrl.list.isLoading()

    m 'ol.things', ctrl.list.map (thing)->
      m 'li',
        m 'input', onchange: ctrl.update.bind(thing), value: thing.get('name')


m.mount(document.getElementById("things"), Things)
```

## Client-side Inbound Events

> load

populdate a client-side table from RethinkDB.  You can add params to it which are passed to a [filter](https://github.com/ondreian/mithink/blob/master/src/server/actions.coffee#L4-L7)

> sync

When an update is attempted, but failed due to any reason, the table on the client side resyncs the document that failed to update by to the originally value and emits an `http_error`

> remove

Whenever a document is deleted from RethinkDB, this event is received and updates the client-side table replicate if the document exists in the table replicate.

> upsert

Whenever a document was updated or created on the server.  It transparently adds it to the `r.table(tableName)` in the background and triggers a redraw (if there are no diffs in the HTML this is a no-op).

> http_error

Anytime something unexpected occurs, from a failed permission check to a failed validation check.  The event data returned is structured like this:

```coffeescript
{
  code    : code
  message : err.message
  raw     : err
  data    : data
  table   : "Things"
  action  : "action"
}
```
