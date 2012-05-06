(function() {
  var _, _base, _ref;
  var __slice = Array.prototype.slice;

  _ = require('underscore');

  _.defaults(this, {
    YouAreDaChef: function() {
      var advise, clazzes, combinator;
      clazzes = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      advise = function(verb, advice, namespace, pointcut_exprs) {
        return _.each(clazzes, function(clazz) {
          var daemonize, expr;
          daemonize = function(name, inject) {
            var daemonology, key, _base, _ref, _ref2;
            if (inject == null) inject = [];
            daemonology = (_ref = (_base = ((_ref2 = clazz.__YouAreDaChef) != null ? _ref2 : clazz.__YouAreDaChef = {}))[name]) != null ? _ref : _base[name] = {};
            _.defaults(daemonology, {
              before: [],
              after: [],
              around: [],
              guard: []
            });
            if (!clazz.prototype.hasOwnProperty("before_" + name + "_daemon")) {
              clazz.prototype["before_" + name + "_daemon"] = function() {
                var args, daemon, daemon_args, _i, _len, _ref3, _ref4, _ref5;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                daemon_args = inject.concat(args);
                _ref3 = daemonology.before.reverse();
                for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
                  daemon = _ref3[_i];
                  if (_.isFunction(daemon)) {
                    daemon.apply(this, daemon_args);
                  } else if (_.isArray(daemon)) {
                    daemon[1].apply(this, daemon_args);
                  } else {
                    _.values(daemon)[0].apply(this, daemon_args);
                  }
                }
                return (_ref4 = clazz.__super__) != null ? (_ref5 = _ref4["before_" + name + "_daemon"]) != null ? _ref5.apply(this, args) : void 0 : void 0;
              };
              clazz.prototype["after_" + name + "_daemon"] = function() {
                var args, daemon, daemon_args, _i, _len, _ref3, _ref4, _ref5, _results;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                daemon_args = inject.concat(args);
                if ((_ref3 = clazz.__super__) != null) {
                  if ((_ref4 = _ref3["after_" + name + "_daemon"]) != null) {
                    _ref4.apply(this, args);
                  }
                }
                _ref5 = daemonology.after;
                _results = [];
                for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
                  daemon = _ref5[_i];
                  if (_.isFunction(daemon)) {
                    _results.push(daemon.apply(this, daemon_args));
                  } else if (_.isArray(daemon)) {
                    _results.push(daemon[1].apply(this, daemon_args));
                  } else {
                    _results.push(_.values(daemon)[0].apply(this, daemon_args));
                  }
                }
                return _results;
              };
              clazz.prototype["around_" + name + "_daemon"] = function() {
                var args, daemon, daemon_args, default_fn, fn, fn_list, _i, _len, _ref3, _ref4, _ref5;
                var _this = this;
                default_fn = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
                daemon_args = inject.concat(args);
                fn_list = [];
                if (((_ref3 = clazz.__super__) != null ? _ref3["around_" + name + "_daemon"] : void 0) != null) {
                  fn_list.unshift((_ref4 = clazz.__super__) != null ? _ref4["around_" + name + "_daemon"] : void 0);
                }
                _ref5 = daemonology.around;
                for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
                  daemon = _ref5[_i];
                  if (_.isFunction(daemon)) {
                    fn_list.unshift(daemon);
                  } else if (_.isArray(daemon)) {
                    fn_list.unshift(daemon[1]);
                  } else {
                    fn_list.unshift(_.values(daemon)[0]);
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
                  return default_fn.apply(_this, args);
                });
                return fn.apply(this, args);
              };
              clazz.prototype["guard_" + name + "_daemon"] = function() {
                var args, daemon, daemon_args, _i, _len, _ref3, _ref4, _ref5;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                daemon_args = inject.concat(args);
                if (((_ref3 = clazz.__super__) != null ? _ref3["guard_" + name + "_daemon"] : void 0) != null) {
                  if (!((_ref4 = clazz.__super__) != null ? _ref4["guard_" + name + "_daemon"].apply(this, args) : void 0)) {
                    return false;
                  }
                }
                _ref5 = daemonology.guard;
                for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
                  daemon = _ref5[_i];
                  if (_.isFunction(daemon)) {
                    if (!daemon.apply(this, daemon_args)) return false;
                  } else if (_.isArray(daemon)) {
                    if (!daemon[1].apply(this, daemon_args)) return false;
                  } else {
                    !!_.values(daemon)[0].apply(this, daemon_args);
                  }
                }
                return true;
              };
            }
            if (!(clazz.prototype.hasOwnProperty(name) && (daemonology["default"] != null))) {
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
                var args, default_daemon, _ref3;
                var _this = this;
                args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                if (_.isFunction(daemonology["default"])) {
                  default_daemon = daemonology["default"];
                } else if (_.isArray(daemonology["default"])) {
                  default_daemon = daemon[1];
                } else {
                  default_daemon = _.values(daemonology["default"])[0];
                }
                if (clazz.prototype["guard_" + name + "_daemon"].apply(this, args)) {
                  clazz.prototype["before_" + name + "_daemon"].apply(this, args);
                  return _.tap((_ref3 = clazz.prototype["around_" + name + "_daemon"]).call.apply(_ref3, [this, default_daemon].concat(__slice.call(args))), function(retv) {
                    return clazz.prototype["after_" + name + "_daemon"].apply(_this, args);
                  });
                }
              };
            }
            if (namespace != null) {
              if (_.isFunction(advice)) {
                advice = _.tap({}, function(h) {
                  return h["" + namespace + ": " + (daemonology[verb].length + 1)] = advice;
                });
              } else if (_.isArray(advice)) {
                advice = _.tap({}, function(h) {
                  return h["" + namespace + ": " + advice[0]] = advice[1];
                });
              } else {
                key = _.keys(advice)[0];
                advice = _.tap({}, function(h) {
                  return h["" + namespace + ": " + key] = advice[key];
                });
              }
            }
            if (verb === 'default') {
              return daemonology["default"] = advice;
            } else {
              return daemonology[verb].push(advice);
            }
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
                throw 'Specify a pointcut with a single regular expression or a list of strings';
              }
            });
          }
          return clazz.__YouAreDaChef;
        });
      };
      return combinator = {
        _namespace: null,
        "default": function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('default', advice, this._namespace, pointcut_exprs);
          return combinator;
        },
        before: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('before', advice, this._namespace, pointcut_exprs);
          return combinator;
        },
        after: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('after', advice, this._namespace, pointcut_exprs);
          return combinator;
        },
        around: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('around', advice, this._namespace, pointcut_exprs);
          return combinator;
        },
        guard: function() {
          var advice, pointcut_exprs, _i;
          pointcut_exprs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), advice = arguments[_i++];
          advise('guard', advice, this._namespace, pointcut_exprs);
          return combinator;
        },
        namespace: function(str) {
          this._namespace = str;
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
