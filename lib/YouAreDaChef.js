(function() {
  var _, _base, _ref;
  var __slice = Array.prototype.slice;

  _ = require('underscore');

  _.defaults(this, {
    YouAreDaChef: function() {
      var advise, clazzes, combinator;
      clazzes = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      advise = function(verb, advice, pointcut_exprs) {
        return _.each(clazzes, function(clazz) {
          var daemonize, expr;
          daemonize = function(name, inject) {
            var daemonology, _base, _base2, _base3, _base4, _base5, _name, _name2, _name3, _name4, _ref, _ref2, _ref3, _ref4, _ref5, _ref6;
            if (inject == null) inject = [];
            daemonology = (_ref = (_base = ((_ref2 = clazz.__YouAreDaChef) != null ? _ref2 : clazz.__YouAreDaChef = {}))[name]) != null ? _ref : _base[name] = {};
            _.defaults(daemonology, {
              before: [],
              after: [],
              around: [],
              guard: []
            });
            if ((_ref3 = (_base2 = clazz.prototype)[_name = "before_" + name + "_daemon"]) == null) {
              _base2[_name] = function() {
                var advice, args, daemon, daemon_args, name, _i, _len, _ref4, _ref5, _ref6;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                daemon_args = inject.concat(args);
                _ref4 = daemonology.before.reverse();
                for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
                  daemon = _ref4[_i];
                  if (_.isFunction(daemon)) {
                    daemon.apply(this, daemon_args);
                  } else if (_.isArray(daemon)) {
                    daemon[1].apply(this, daemon_args);
                  } else {
                    for (name in daemon) {
                      advice = daemon[name];
                      advice.apply(this, args);
                    }
                  }
                }
                return (_ref5 = clazz.__super__) != null ? (_ref6 = _ref5["before_" + name + "_daemon"]) != null ? _ref6.apply(this, args) : void 0 : void 0;
              };
            }
            if ((_ref4 = (_base3 = clazz.prototype)[_name2 = "after_" + name + "_daemon"]) == null) {
              _base3[_name2] = function() {
                var advice, args, daemon, daemon_args, name, _i, _len, _ref5, _ref6, _ref7, _results;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                daemon_args = inject.concat(args);
                if ((_ref5 = clazz.__super__) != null) {
                  if ((_ref6 = _ref5["after_" + name + "_daemon"]) != null) {
                    _ref6.apply(this, args);
                  }
                }
                _ref7 = daemonology.after;
                _results = [];
                for (_i = 0, _len = _ref7.length; _i < _len; _i++) {
                  daemon = _ref7[_i];
                  if (_.isFunction(daemon)) {
                    _results.push(daemon.apply(this, daemon_args));
                  } else if (_.isArray(daemon)) {
                    _results.push(daemon[1].apply(this, daemon_args));
                  } else {
                    _results.push((function() {
                      var _results2;
                      _results2 = [];
                      for (name in daemon) {
                        advice = daemon[name];
                        _results2.push(advice.apply(this, daemon_args));
                      }
                      return _results2;
                    }).call(this));
                  }
                }
                return _results;
              };
            }
            if ((_ref5 = (_base4 = clazz.prototype)[_name3 = "around_" + name + "_daemon"]) == null) {
              _base4[_name3] = function() {
                var advice, args, daemon, daemon_args, fn, fn_list, name, _i, _len, _ref6, _ref7, _ref8;
                var _this = this;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                daemon_args = inject.concat(args);
                fn_list = [];
                if (((_ref6 = clazz.__super__) != null ? _ref6["around_" + name + "_daemon"] : void 0) != null) {
                  fn_list.unshift((_ref7 = clazz.__super__) != null ? _ref7["around_" + name + "_daemon"] : void 0);
                }
                _ref8 = daemonology.around;
                for (_i = 0, _len = _ref8.length; _i < _len; _i++) {
                  daemon = _ref8[_i];
                  if (_.isFunction(daemon)) {
                    fn_list.unshift(daemon);
                  } else if (_.isArray(daemon)) {
                    fn_list.unshift(daemon[1]);
                  } else {
                    for (name in daemon) {
                      advice = daemon[name];
                      fn_list.unshift(advice);
                    }
                  }
                }
                fn = _.reduce(fn_list, function(acc, advice) {
                  return function() {
                    var args;
                    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                    return advice.call.apply(advice, [this, acc].concat(__slice.call(daemon_args)));
                  };
                }, function() {
                  var args;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  return daemonology["default"].apply(_this, args);
                });
                return fn.apply(this, args);
              };
            }
            if ((_ref6 = (_base5 = clazz.prototype)[_name4 = "guard_" + name + "_daemon"]) == null) {
              _base5[_name4] = function() {
                var advice, args, daemon, daemon_args, name, _i, _len, _ref7, _ref8, _ref9;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                daemon_args = inject.concat(args);
                if (((_ref7 = clazz.__super__) != null ? _ref7["guard_" + name + "_daemon"] : void 0) != null) {
                  if (!((_ref8 = clazz.__super__) != null ? _ref8["guard_" + name + "_daemon"].apply(this, args) : void 0)) {
                    return false;
                  }
                }
                _ref9 = daemonology.guard;
                for (_i = 0, _len = _ref9.length; _i < _len; _i++) {
                  daemon = _ref9[_i];
                  if (_.isFunction(daemon)) {
                    if (!daemon.apply(this, daemon_args)) return false;
                  } else if (_.isArray(daemon)) {
                    if (!daemon[1].apply(this, daemon_args)) return false;
                  } else {
                    for (name in daemon) {
                      advice = daemon[name];
                      if (!advice.apply(this, daemon_args)) return false;
                    }
                  }
                }
                return true;
              };
            }
            if (!((clazz.prototype[name] != null) && (daemonology["default"] != null))) {
              if (_.include(_.keys(clazz.prototype), name)) {
                daemonology["default"] = clazz.prototype[name];
              } else if (clazz.__super__ != null) {
                daemonology["default"] = function() {
                  var args;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  return clazz.__super__[name].apply(this, args);
                };
              } else {
                throw 'No method or superclass given ' + name;
              }
              clazz.prototype[name] = function() {
                var args;
                var _this = this;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                if (clazz.prototype["guard_" + name + "_daemon"].apply(this, args)) {
                  clazz.prototype["before_" + name + "_daemon"].apply(this, args);
                  return _.tap(clazz.prototype["around_" + name + "_daemon"].apply(this, args), function(retv) {
                    return clazz.prototype["after_" + name + "_daemon"].apply(_this, args);
                  });
                }
              };
            }
            return daemonology[verb].push(advice);
          };
          if (pointcut_exprs.length === 1 && (expr = pointcut_exprs[0]) instanceof RegExp) {
            _.each(_.functions(clazz.prototype), function(name) {
              var match_data;
              if (match_data = name.match(expr)) {
                return daemonize(name, match_data);
              }
            });
          } else {
            _.each(pointcut_exprs, function(expr) {
              if (_.isString(expr) && _.isFunction(clazz.prototype[expr])) {
                return daemonize(expr);
              } else {
                throw 'Specify a pointcut witha single regular expression or a list of strings';
              }
            });
          }
          return clazz.__YouAreDaChef;
        });
      };
      return combinator = {
        before: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('before', advice, pointcut_exprs);
          return combinator;
        },
        after: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('after', advice, pointcut_exprs);
          return combinator;
        },
        around: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('around', advice, pointcut_exprs);
          return combinator;
        },
        guard: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('guard', advice, pointcut_exprs);
          return combinator;
        }
      };
    }
  });

  if ((_ref = (_base = this.YouAreDaChef).inspect) == null) {
    _base.inspect = function(clazz) {
      return clazz.__YouAreDaChef;
    };
  }

  this;

}).call(this);
