expect  = require('chai').expect
should  = require('chai').should()
mithink = require '../src'

hasInstanceMethod = (m, prop)->
  expect(m).to.have.property(prop).and.is.a('function')

describe "Server", ->
  m  = require('./fixtures/server').mithink
  # fake socket.io instance for initial tests
  io = {}

  describe "mithink(config)", ->

    it "returns a Mithink instance", ->
      instance = mithink()
      hasInstanceMethod(instance, 'createModel')
      hasInstanceMethod(instance, 'bus')
      hasInstanceMethod(instance, 'proxy')
      return

  describe "Mithink Instance", ->

    it "mithink#createModel", ->
      m.createModel "Animal", {
        name: String
      }

    it "mithink#bus", ->
      should.not.Throw ->
        instance = mithink()
        instance.bus(io)

    #it "mithink#proxy", ->
    #  m.proxy 'createMode', 

    #it 'mithink.$', ->
    #  expect(m.$).to.be.a('object')