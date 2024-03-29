// Generated by CoffeeScript 1.9.0
var Table, m;

m = require('mithril');


/* 
 * @title Client - Table
 * @class Table
 * @overview Base class to inherit from to make writing an adapter easier
 */

module.exports = Table = (function() {
  Table.Row = require('./Row');

  Table.create = function(rows) {
    if (rows == null) {
      rows = [];
    }
    return new this(rows);
  };

  function Table(rows) {
    if (rows == null) {
      rows = [];
    }
    this._loading = false;
    this;
  }

  Table.prototype.finishLoading = function() {
    this._loading = false;
    return this;
  };

  Table.prototype.isLoading = function() {
    return this._loading || false;
  };

  Table.prototype.rows = function(rowsToAdd) {};

  Table.prototype.remove = function(query) {};

  Table.prototype.add = function(adding) {};

  Table.prototype.reset = function(rows) {};

  Table.prototype.get = function(id) {};

  Table.prototype.all = function() {};

  Table.prototype.at = function(index) {};

  Table.prototype.length = function() {};

  Table.prototype.toJSON = function() {};

  Table.prototype.on = function(evt, handler) {
    this.channel.on(evt, handler);
    return this;
  };

  Table.prototype.once = function(evt, handler) {
    this.channel.once(evt, handler);
    return this;
  };

  Table.prototype.emit = function(evt, data) {
    this.channel.emit(evt, data);
    return this;
  };

  return Table;

})();

Table.handlers = {
  load: function(data) {
    throw new Error("your adapter should override Table.handlers.load");
  },
  upsert: function(doc) {
    throw new Error("your adapter should override Table.handlers.upsert");
  },
  destroy: function(doc) {
    throw new Error("your adapter should override Table.handlers.destroy");
  },
  sync: function(doc) {
    throw new Error("your adapter should override Table.handlers.sync");
  }
};
