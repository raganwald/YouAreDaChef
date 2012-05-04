(function() {
  var invoke, _;
  var __slice = Array.prototype.slice;

  if (typeof _ === "undefined" || _ === null) _ = require('underscore');

  invoke = function() {
    var args, method_name;
    method_name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (_.isFunction(this.actual[method_name])) {
      return this.actual[method_name].apply(this.actual, args);
    } else {
      args.unshift(this.actual);
      return _[method_name].apply(this.actual, args);
    }
  };

  _.defaults(jasmine.Matchers.prototype, {
    toBeEmpty: function() {
      return invoke.call(this, 'isEmpty');
    },
    toInclude: function() {
      var items;
      var _this = this;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _(items).all(function(item) {
        return invoke.call(_this, 'include', item);
      });
    },
    toIncludeAny: function() {
      var items;
      var _this = this;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _(items).any(function(item) {
        return invoke.call(_this, 'include', item);
      });
    },
    toBeCompact: function() {
      var elements;
      elements = invoke.call(this, 'map', _.identity);
      return _.isEqual(elements, _.compact(elements));
    },
    toBeUnique: function() {
      var elements;
      elements = invoke.call(this, 'map', _.identity);
      return _.isEqual(elements, _.uniq(elements));
    },
    toRespondTo: function() {
      var methods;
      var _this = this;
      methods = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _.all(methods, function(method) {
        return _.isFunction(_this.actual[method]);
      });
    },
    toRespondToAny: function() {
      var methods;
      var _this = this;
      methods = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _.any(methods, function(method) {
        return _.isFunction(_this.actual[method]);
      });
    },
    toHave: function() {
      var attrs;
      var _this = this;
      attrs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _.all(attrs, function(attr) {
        return _this.actual.has(attr);
      });
    },
    toHaveAny: function() {
      var attrs;
      var _this = this;
      attrs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _.any(attrs, function(attr) {
        return _this.actual.has(attr);
      });
    },
    toBeAnInstanceOf: function(clazz) {
      return this.actual instanceof clazz;
    },
    toBeA: function(clazz) {
      return this.actual instanceof clazz;
    },
    toBeAn: function(clazz) {
      return this.actual instanceof clazz;
    }
  });

}).call(this);
