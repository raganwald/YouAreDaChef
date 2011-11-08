(function() {
  var _;
  var __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  _ = require('underscore');
  _.defaults(this, {
    YouAreDaChef: function() {
      var clazzes, combinator;
      clazzes = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return combinator = {
        before: function() {
          var advice, method_names, _i;
          method_names = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          _.each(method_names, function(name) {
            return _.each(clazzes, function(clazz) {
              var pointcut;
              if (_.isFunction(clazz.prototype[name])) {
                pointcut = clazz.prototype[name];
                return clazz.prototype[name] = function() {
                  var args;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  advice.apply(this, args);
                  return pointcut.apply(this, args);
                };
              }
            });
          });
          return combinator;
        },
        after: function() {
          var advice, method_names, _i;
          method_names = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          _.each(method_names, function(name) {
            return _.each(clazzes, function(clazz) {
              var pointcut;
              if (_.isFunction(clazz.prototype[name])) {
                pointcut = clazz.prototype[name];
                return clazz.prototype[name] = function() {
                  var args;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  return _.tap(pointcut.apply(this, args), __bind(function() {
                    return advice.apply(this, args);
                  }, this));
                };
              }
            });
          });
          return combinator;
        },
        around: function() {
          var advice, method_names, _i;
          method_names = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          _.each(method_names, function(name) {
            return _.each(clazzes, function(clazz) {
              var pointcut;
              if (_.isFunction(clazz.prototype[name])) {
                pointcut = clazz.prototype[name];
                return clazz.prototype[name] = function() {
                  var args, bound_pointcut;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  bound_pointcut = __bind(function() {
                    var args2;
                    args2 = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                    return pointcut.apply(this, args2);
                  }, this);
                  return advice.call.apply(advice, [this, bound_pointcut].concat(__slice.call(args)));
                };
              }
            });
          });
          return combinator;
        },
        guard: function() {
          var advice, method_names, _i;
          method_names = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          _.each(method_names, function(name) {
            return _.each(clazzes, function(clazz) {
              var pointcut;
              if (_.isFunction(clazz.prototype[name])) {
                pointcut = clazz.prototype[name];
                return clazz.prototype[name] = function() {
                  var args;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  if (advice.apply(this, args)) {
                    return pointcut.apply(this, args);
                  }
                };
              }
            });
          });
          return combinator;
        }
      };
    }
  });
}).call(this);
