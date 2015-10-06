expect  = require('chai').expect

describe "Model", ->
  app     = require './fixtures/server'
  Thing   = app.models.Thing

  describe "Model.channel", ->
    it "is an instance of Socket.io Namespace", ->
      expect(Thing).to.have.property('channel')
      expect(Thing.channel.on).to.be.a('function')
      #expect(Thing.channel.off).to.be.a('function')
      expect(Thing.channel.once).to.be.a('function')

  describe "Model#guard", ->

    it "allows for access control", ->
      Thing.guard {
        connection: (socket)->
          return socket.isAuthenticated
      }


  describe "Model#registerActions", ->
    it "registers custom Client events that a Model can listen to", ->
      Thing.registerActions {
        pivot: (data)->
          socket = @socket
          table  = @table
          table.group(data.key).run().then (pivoted)->
            socket.emit "pivot:#{data.key}", pivoted
      }
