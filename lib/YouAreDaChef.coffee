_ = require 'underscore'

class Combinator
  constructor: (args...) ->
    @clazzes []
    @methods []
    @for(args...)
    this

  namespace: (name = null) ->
    if name?
      @_namespace = name
      this
    else @_namespace

  clazzes: (args...) ->
    if args.length > 0
      @_clazzes = args
      this
    else @_clazzes

  methods: (args...) ->
    if args.length > 0
      @_methods = args
      this
    else @_methods

  for: (args...) ->
    if args.length > 0 and _.all(args, _.isFunction)
      @clazzes(args...)
    else if args.length is 1
      if _.isString(args[0])
        @namespace( args[0] )
      else
        @namespace( _.keys(args[0])[0] )
        clazz_arg = args[0][@namespace()]
        if _.isArray(clazz_arg)
          @clazzes(clazz_arg...)
        else if _.isFunction(clazz_arg)
          @clazzes(clazz_arg)
        else throw "What do I do with { #{@namespace()}: #{clazz_arg} }?"
    this

  advise: (verb, advice, namespace, clazzes, pointcut_exprs) ->
    if verb is 'unless'
      verb = 'guard'
      _advice = advice
      advice = (args...) ->
        !_advice.apply(this, args)
    throw "Need to define one or more classes" unless clazzes.length
    _.each clazzes, (clazz) ->
      daemonize = (name, inject = []) ->
        daemonology = (clazz.__YouAreDaChef ?= {})[name] ?= {}
        _.defaults daemonology,
          before: []
          after: []
          around: []
          guard: []
          default: []

        unless clazz.prototype.hasOwnProperty("before_#{name}_daemon")

          clazz.prototype["before_#{name}_daemon"] = (args...) ->
            daemon_args = inject.concat args
            # try a super-daemon if available
            # execute specific daemons for side-effects
            for daemon in daemonology.before.reverse()
              daemon[1].apply(this, daemon_args)
            # try a super-daemon if available
            clazz.__super__?["before_#{name}_daemon"]?.apply(this, args)

          clazz.prototype["after_#{name}_daemon"] = (args...) ->
            daemon_args = inject.concat args
            # try a super-daemon if available
            clazz.__super__?["after_#{name}_daemon"]?.apply(this, args)
            # execute specific daemons for side-effects
            for daemon in daemonology.after
              daemon[1].apply(this, daemon_args)

          clazz.prototype["around_#{name}_daemon"] = (default_fn, args...) ->
            daemon_args = inject.concat args
            fn_list = []
            # try a super-daemon if available
            if clazz.__super__?["around_#{name}_daemon"]?
              fn_list.unshift clazz.__super__?["around_#{name}_daemon"]
            # specific daemons
            for daemon in daemonology.around
              fn_list.unshift daemon[1]

            fn = _.reduce fn_list, (acc, advice) ->
              (args...) -> advice.call(this, acc, daemon_args...)
            , (args...) =>
              default_fn.apply(this, args)
            fn.apply(this, args)

          clazz.prototype["guard_#{name}_daemon"] = (args...) ->
            daemon_args = inject.concat args
            # try a super-daemon if available
            if clazz.__super__?["guard_#{name}_daemon"]?
              return false unless clazz.__super__?["guard_#{name}_daemon"].apply(this, args)
            # specific daemons
            for daemon in daemonology.guard
              return false unless daemon[1].apply(this, daemon_args)
            true

        # this patches the original method to call advices and pass match data
        unless clazz.prototype.hasOwnProperty(name) and daemonology.default.length > 0
          if _.include(_.keys(clazz.prototype), name)
            daemonology.default.push ['Combinator: 1', clazz.prototype[name]]
          else if clazz.__super__?
            daemonology.default.push ['Combinator: 1', (args...) ->
              clazz.__super__[name].apply(this, args)
            ]
          else if clazz::__proto__?
            daemonology.default.push ['Combinator: 1', (args...) ->
              clazz::__proto__[name].apply(this, args)
            ]
          else
            daemonology.default.push ['Combinator: 1', (args...) ->
              throw 'No method or superclass defined for ' + name
            ]
          clazz.prototype[name] = (args...) ->
            if clazz.prototype["guard_#{name}_daemon"].apply(this, args)
              clazz.prototype["before_#{name}_daemon"].apply(this, args)
              _.tap clazz.prototype["around_#{name}_daemon"].call(this, _.last(daemonology.default)[1], args...), (retv) =>
                clazz.prototype["after_#{name}_daemon"].apply(this, args)

        # Add the advice to the appropriate list
        if namespace?
          if _.isFunction(advice)
            advice = ["#{namespace}: #{daemonology[verb].length + 1}", advice]
          else if _.isArray(advice)
            advice = ["#{namespace}: #{advice[0]}", advice[1]]
          else
            key = _.keys(advice)[0]
            advice = ["#{namespace}: #{key}", advice[key]]
        else
          if _.isFunction(advice)
            advice = ["#{daemonology[verb].length + 1}", advice]
          else if _.isArray(advice)
            # fine!
          else
            key = _.keys(advice)[0]
            advice = [key, advice[key]]
        daemonology[verb].push advice

      if pointcut_exprs.length is 1 and (expr = pointcut_exprs[0]) instanceof RegExp
        _.each _.functions(clazz.prototype), (name) ->
          if match_data = name.match(expr)
            daemonize name, match_data
      else
        _.each pointcut_exprs, (name) ->
          if _.isString(name)
            if verb is 'default' and !clazz.prototype["before_#{name}_daemon"] and _.isFunction(advice) # not hasOwnProperty, anywhere in the chain!
                clazz.prototype[name] = advice
            else daemonize name
          else throw 'Specify a pointcut with a single regular expression or a list of strings'

      clazz.__YouAreDaChef

_.each ['default', 'before', 'around', 'after', 'guard', 'unless'], (verb) ->
  Combinator.prototype[verb] = (args...) ->
    if args.length is 1
      if _.isFunction(args[0])
        # default syntax
        @advise verb, args[0], @namespace(), @clazzes(), @methods()
      else
        # bulk syntax
        for own expr, advice of args[0]
          @advise verb, advice, @namespace(), @clazzes(), [expr]
    else if args.length > 1 and _.isString(args[0]) or args[0] instanceof RegExp
      # classic syntax
      [pointcut_exprs..., advice] = args
      @advise verb, advice, @namespace(), @clazzes(), pointcut_exprs
    else throw "What do I do with #{args} for #{verb}?"
    this

Combinator::def = Combinator::define = Combinator::default
Combinator::when = Combinator::guard
Combinator::except_when = Combinator::unless
Combinator::tag = Combinator::namespace
Combinator::method = Combinator::methods
Combinator::clazz = Combinator::clazzes

YouAreDaChef = (args...) ->
  new Combinator(args...)

_.each ['for', 'namespace', 'clazz', 'method', 'clazzes', 'methods', 'tag'], (definition_method_name) ->
  YouAreDaChef[definition_method_name] = (args...) ->
    _.tap new Combinator(), (combinator) ->
      combinator[definition_method_name](args...)

_.extend YouAreDaChef,
  inspect: (clazz) ->
    clazz.__YouAreDaChef

module.exports = YouAreDaChef
_.defaults module.exports, {YouAreDaChef}
this
