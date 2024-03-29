// Generated by CoffeeScript 1.9.0
var Bus, Mithink, t,
  __slice = [].slice;

t = require("thinky");

Bus = require('./bus');


/**
 * Function to create a server-side Mithink instance, accepts the options arguments as defined in {@link http://thinky.io/documentation/api/thinky/ thinky()}
 * @namespace Mithink.Server
 * @type Function
 * @param {Object} options - the thinky options object
 * @example
 * var mithink = require('mithink')();
 */

Mithink = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  Mithink.$ = t.apply(t, args);
  Mithink.r = Mithink.$.r;
  Mithink.type = Mithink.$.type;
  Mithink.Query = Mithink.$.Query;
  Mithink.Errors = Mithink.$.Errors;
  return Mithink;
};


/**
 * Function to register a socket.io instance with Mithink
 * @memberof Mithink.Server
 * @function Mithink.Server.bus 
 * @param {Socket.IO} io - the socket.io instance to use for syncing data
 * @example
 * var io = require('socket.io')()
 * var mithink = require('mithink')()
 * mithink.bus(io)
 */

Mithink.bus = function(io) {
  Bus(io);
  return Mithink;
};


/**
 * Proxy a function call to the internal thinky object as defined {@link http://thinky.io/documentation/api/thinky/ here}
 * @memberof Mithink.Server
 * @function Mithink.Server.proxy 
 * @param {String} method - the method to execute on Thinky
 * @param {Array} args - the arguments to apply on the method
 * @example
 * mithink.proxy "createModel", [schema]
 */

Mithink.proxy = function(method, args) {
  if (!Mithink.$) {
    throw new Error("thinky has not been initialized, please see http://thinky.io/documentation");
  }
  return Mithink.$[method].apply(Mithink.$, args);
};


/**
 * convience wrapper for thinky.createModel that wires up an Thinky.Model extended with Mithink features
 * @memberof Mithink.Server
 * @function Mithink.Server.createModel
 * @param {String} name - the method to execute on Thinky
 * @param {Object} schema - the arguments to apply on the method
 * @param {Object} options - the options
 * @returns {Server.Model}
 * @example
 * Thing = mithink.createModel 'Thing', {
 *    id        : type.string()
 *    name      : type.string()
 *  }
 */

Mithink.createModel = function() {
  var args, model;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  model = Mithink.proxy('createModel', args);
  Bus.extend(model).wireUp(model);
  return model;
};

module.exports = Mithink;
