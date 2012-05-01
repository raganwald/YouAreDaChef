(function() {
  var _;
  var __slice = Array.prototype.slice;

  _ = require('underscore');

  _.defaults(this, {
    YouAreDaChef: function() {
      var clazzes, combinator, pointcuts;
      clazzes = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      pointcuts = function(pointcut_exprs) {
        return _.tap({}, function(cuts) {
          return _.each(clazzes, function(clazz) {
            return _.each(pointcut_exprs, function(expr) {
              var name, pointcut;
              if (_.isString(expr) && _.isFunction(clazz.prototype[expr])) {
                name = expr;
                if (_.include(_.keys(clazz.prototype), name)) {
                  pointcut = clazz.prototype[name];
                } else if (clazz.__super__ != null) {
                  pointcut = function() {
                    var args;
                    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                    return clazz.__super__[name].apply(this, args);
                  };
                } else {
                  throw 'No method or superclass given ' + name;
                }
                return cuts[name] = {
                  clazz: clazz,
                  pointcut: pointcut,
                  inject: []
                };
              } else if (expr instanceof RegExp) {
                return _.each(_.functions(clazz.prototype), function(name) {
                  var match;
                  if (match = name.match(expr)) {
                    if (_.include(_.keys(clazz.prototype), name)) {
                      pointcut = clazz.prototype[name];
                    } else if (clazz.__super__ != null) {
                      pointcut = function() {
                        var args;
                        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                        return clazz.__super__[name].apply(this, args);
                      };
                    } else {
                      throw 'No method or superclass given ' + name;
                    }
                    return cuts[name] = {
                      clazz: clazz,
                      pointcut: pointcut,
                      inject: match
                    };
                  }
                });
              }
            });
          });
        });
      };
      return combinator = {
        before: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          _.each(pointcuts(pointcut_exprs), function(_arg, name) {
            var clazz, inject, pointcut;
            clazz = _arg.clazz, pointcut = _arg.pointcut, inject = _arg.inject;
            return clazz.prototype[name] = function() {
              var args;
              args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              advice.call.apply(advice, [this].concat(__slice.call(inject), __slice.call(args)));
              return pointcut.apply(this, args);
            };
          });
          return combinator;
        },
        after: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          _.each(pointcuts(pointcut_exprs), function(_arg, name) {
            var clazz, inject, pointcut;
            clazz = _arg.clazz, pointcut = _arg.pointcut, inject = _arg.inject;
            return clazz.prototype[name] = function() {
              var args;
              var _this = this;
              args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              return _.tap(pointcut.apply(this, args), function() {
                return advice.call.apply(advice, [_this].concat(__slice.call(inject), __slice.call(args)));
              });
            };
          });
          return combinator;
        },
        around: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          _.each(pointcuts(pointcut_exprs), function(_arg, name) {
            var clazz, inject, pointcut;
            clazz = _arg.clazz, pointcut = _arg.pointcut, inject = _arg.inject;
            return clazz.prototype[name] = function() {
              var args, bound_pointcut;
              var _this = this;
              args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              bound_pointcut = function() {
                var args2;
                args2 = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                return pointcut.apply(_this, args2);
              };
              return advice.call.apply(advice, [this, bound_pointcut].concat(__slice.call(inject), __slice.call(args)));
            };
          });
          return combinator;
        },
        guard: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          _.each(pointcuts(pointcut_exprs), function(_arg, name) {
            var clazz, inject, pointcut;
            clazz = _arg.clazz, pointcut = _arg.pointcut, inject = _arg.inject;
            return clazz.prototype[name] = function() {
              var args;
              args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              if (advice.call.apply(advice, [this].concat(__slice.call(inject), __slice.call(args)))) {
                return pointcut.apply(this, args);
              }
            };
          });
          return combinator;
        }
      };
    }
  });

}).call(this);
