(function() {
  var Combinator, YouAreDaChef, _;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty;

  _ = require('underscore');

  Combinator = (function() {

    function Combinator() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.clazzes([]);
      this.methods([]);
      this["for"].apply(this, args);
      this;
    }

    Combinator.prototype.namespace = function(name) {
      if (name == null) name = null;
      if (name != null) {
        this._namespace = name;
        return this;
      } else {
        return this._namespace;
      }
    };

    Combinator.prototype.clazzes = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length > 0) {
        this._clazzes = args;
        return this;
      } else {
        return this._clazzes;
      }
    };

    Combinator.prototype.methods = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length > 0) {
        this._methods = args;
        return this;
      } else {
        return this._methods;
      }
    };

    Combinator.prototype["for"] = function() {
      var args, clazz_arg;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length > 0 && _.all(args, _.isFunction)) {
        this.clazzes.apply(this, args);
      } else if (args.length === 1) {
        if (_.isString(args[0])) {
          this.namespace(args[0]);
        } else {
          this.namespace(_.keys(args[0])[0]);
          clazz_arg = args[0][this.namespace()];
          if (_.isArray(clazz_arg)) {
            this.clazzes.apply(this, clazz_arg);
          } else if (_.isFunction(clazz_arg)) {
            this.clazzes(clazz_arg);
          } else {
            throw "What do I do with { " + (this.namespace()) + ": " + clazz_arg + " }?";
          }
        }
      }
      return this;
    };

    Combinator.prototype.advise = function(verb, advice, namespace, clazzes, pointcut_exprs) {
      if (!clazzes.length) throw "Need to define one or more classes";
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
            guard: [],
            "default": []
          });
          if (!clazz.prototype.hasOwnProperty("before_" + name + "_daemon")) {
            clazz.prototype["before_" + name + "_daemon"] = function() {
              var args, daemon, daemon_args, _i, _len, _ref3, _ref4, _ref5;
              args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              daemon_args = inject.concat(args);
              _ref3 = daemonology.before.reverse();
              for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
                daemon = _ref3[_i];
                daemon[1].apply(this, daemon_args);
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
                _results.push(daemon[1].apply(this, daemon_args));
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
                fn_list.unshift(daemon[1]);
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
                if (!daemon[1].apply(this, daemon_args)) return false;
              }
              return true;
            };
          }
          if (!(clazz.prototype.hasOwnProperty(name) && daemonology["default"].length > 0)) {
            if (_.include(_.keys(clazz.prototype), name)) {
              daemonology["default"].push(['Combinator: 1', clazz.prototype[name]]);
            } else if (clazz.__super__ != null) {
              daemonology["default"].push([
                'Combinator: 1', function() {
                  var args;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  return clazz.__super__[name].apply(this, args);
                }
              ]);
            } else {
              daemonology["default"].push([
                'Combinator: 1', function() {
                  var args;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  throw 'No method or superclass defined for ' + name;
                }
              ]);
            }
            clazz.prototype[name] = function() {
              var args, _ref3;
              var _this = this;
              args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              if (clazz.prototype["guard_" + name + "_daemon"].apply(this, args)) {
                clazz.prototype["before_" + name + "_daemon"].apply(this, args);
                return _.tap((_ref3 = clazz.prototype["around_" + name + "_daemon"]).call.apply(_ref3, [this, _.last(daemonology["default"])[1]].concat(__slice.call(args))), function(retv) {
                  return clazz.prototype["after_" + name + "_daemon"].apply(_this, args);
                });
              }
            };
          }
          if (namespace != null) {
            if (_.isFunction(advice)) {
              advice = ["" + namespace + ": " + (daemonology[verb].length + 1), advice];
            } else if (_.isArray(advice)) {
              advice = ["" + namespace + ": " + advice[0], advice[1]];
            } else {
              key = _.keys(advice)[0];
              advice = ["" + namespace + ": " + key, advice[key]];
            }
          } else {
            if (_.isFunction(advice)) {
              advice = ["" + (daemonology[verb].length + 1), advice];
            } else if (_.isArray(advice)) {} else {
              key = _.keys(advice)[0];
              advice = [key, advice[key]];
            }
          }
          return daemonology[verb].push(advice);
        };
        if (pointcut_exprs.length === 1 && (expr = pointcut_exprs[0]) instanceof RegExp) {
          _.each(_.functions(clazz.prototype), function(name) {
            var match_data;
            if (match_data = name.match(expr)) return daemonize(name, match_data);
          });
        } else {
          _.each(pointcut_exprs, function(name) {
            if (_.isString(name)) {
              if (verb === 'default' && !clazz.prototype["before_" + name + "_daemon"] && _.isFunction(advice)) {
                return clazz.prototype[name] = advice;
              } else {
                return daemonize(name);
              }
            } else {
              throw 'Specify a pointcut with a single regular expression or a list of strings';
            }
          });
        }
        return clazz.__YouAreDaChef;
      });
    };

    return Combinator;

  })();

  _.each(['default', 'before', 'around', 'after', 'guard'], function(verb) {
    return Combinator.prototype[verb] = function() {
      var advice, args, expr, pointcut_exprs, _i, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length === 1) {
        if (_.isFunction(args[0])) {
          this.advise(verb, args[0], this.namespace(), this.clazzes(), this.methods());
        } else {
          _ref = args[0];
          for (expr in _ref) {
            if (!__hasProp.call(_ref, expr)) continue;
            advice = _ref[expr];
            this.advise(verb, advice, this.namespace(), this.clazzes(), [expr]);
          }
        }
      } else if (args.length > 1 && _.isString(args[0]) || args[0] instanceof RegExp) {
        pointcut_exprs = 2 <= args.length ? __slice.call(args, 0, _i = args.length - 1) : (_i = 0, []), advice = args[_i++];
        this.advise(verb, advice, this.namespace(), this.clazzes(), pointcut_exprs);
      } else {
        throw "What do I do with " + args + " for " + verb + "?";
      }
      return this;
    };
  });

  Combinator.prototype.def = Combinator.prototype.define = Combinator.prototype["default"];

  Combinator.prototype.tag = Combinator.prototype.namespace;

  Combinator.prototype.method = Combinator.prototype.methods;

  Combinator.prototype.clazz = Combinator.prototype.clazzes;

  YouAreDaChef = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(Combinator, args, function() {});
  };

  _.each(['for', 'namespace', 'clazz', 'method', 'clazzes', 'methods', 'tag'], function(definition_method_name) {
    return YouAreDaChef[definition_method_name] = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _.tap(new Combinator(), function(combinator) {
        return combinator[definition_method_name].apply(combinator, args);
      });
    };
  });

  _.extend(YouAreDaChef, {
    inspect: function(clazz) {
      return clazz.__YouAreDaChef;
    }
  });

  _.defaults(this, {
    YouAreDaChef: YouAreDaChef
  });

  this;

}).call(this);
