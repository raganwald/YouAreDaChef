_ = require 'underscore'

_.defaults this,
  YouAreDaChef: (clazzes...) ->

    advise = (verb, advice, namespace, pointcut_exprs) ->
      _.each clazzes, (clazz) ->
        daemonize = (name, inject = []) ->
          daemonology = (clazz.__YouAreDaChef ?= {})[name] ?= {}
          _.defaults daemonology,
            before: []
            after: []
            around: []
            guard: []

          unless clazz.prototype.hasOwnProperty("before_#{name}_daemon")

            clazz.prototype["before_#{name}_daemon"] = (args...) ->
              daemon_args = inject.concat args
              # try a super-daemon if available
              # execute specific daemons for side-effects
              for daemon in daemonology.before.reverse()
                if _.isFunction(daemon)
                  daemon.apply(this, daemon_args)
                else if _.isArray(daemon)
                  daemon[1].apply(this, daemon_args)
                else _.values(daemon)[0].apply(this, daemon_args)
              # try a super-daemon if available
              clazz.__super__?["before_#{name}_daemon"]?.apply(this, args)

            clazz.prototype["after_#{name}_daemon"] = (args...) ->
              daemon_args = inject.concat args
              # try a super-daemon if available
              clazz.__super__?["after_#{name}_daemon"]?.apply(this, args)
              # execute specific daemons for side-effects
              for daemon in daemonology.after
                if _.isFunction(daemon)
                  daemon.apply(this, daemon_args)
                else if _.isArray(daemon)
                  daemon[1].apply(this, daemon_args)
                else _.values(daemon)[0].apply(this, daemon_args)

            clazz.prototype["around_#{name}_daemon"] = (default_fn, args...) ->
              daemon_args = inject.concat args
              fn_list = []
              # try a super-daemon if available
              if clazz.__super__?["around_#{name}_daemon"]?
                fn_list.unshift clazz.__super__?["around_#{name}_daemon"]
              # specific daemons
              for daemon in daemonology.around
                if _.isFunction(daemon)
                  fn_list.unshift daemon
                else if _.isArray(daemon)
                  fn_list.unshift daemon[1]
                else fn_list.unshift _.values(daemon)[0]

              fn = _.reduce fn_list, (acc, advice) ->
                (args...) -> advice.call(this, acc, daemon_args...)
              , (args...) =>
                default_fn.apply(this, args)
                # daemon = daemonology.default
                # if _.isFunction(daemon)
                #   daemon.apply(this, args)
                # else if _.isArray(daemon)
                #   daemon[1].apply(this, args)
                # else for throw_me_away, advice of daemon
                #   advice.apply(this, args)
              fn.apply(this, args)

            clazz.prototype["guard_#{name}_daemon"] = (args...) ->
              daemon_args = inject.concat args
              # try a super-daemon if available
              if clazz.__super__?["guard_#{name}_daemon"]?
                return false unless clazz.__super__?["guard_#{name}_daemon"].apply(this, args)
              # specific daemons
              for daemon in daemonology.guard
                if _.isFunction(daemon)
                  return false unless daemon.apply(this, daemon_args)
                else if _.isArray(daemon)
                  return false unless daemon[1].apply(this, daemon_args)
                else !!_.values(daemon)[0].apply(this, daemon_args)
              true

          # this patches the original method to call advices and pass match data
          unless clazz.prototype.hasOwnProperty(name) and daemonology.default?
            if _.include(_.keys(clazz.prototype), name)
              daemonology.default = clazz.prototype[name]
            else if clazz.__super__?
              daemonology.default = (args...) ->
                clazz.__super__[name].apply(this, args)
            else
              throw 'No method or superclass given ' + name
            clazz.prototype[name] = (args...) ->
              if _.isFunction(daemonology.default)
                default_daemon = daemonology.default
              else if _.isArray(daemonology.default)
                default_daemon = daemon[1]
              else default_daemon = _.values(daemonology.default)[0]
              if clazz.prototype["guard_#{name}_daemon"].apply(this, args)
                clazz.prototype["before_#{name}_daemon"].apply(this, args)
                _.tap clazz.prototype["around_#{name}_daemon"].call(this, default_daemon, args...), (retv) =>
                  clazz.prototype["after_#{name}_daemon"].apply(this, args)

          # Add the advice to the appropriate list
          if namespace?
            if _.isFunction(advice)
              advice = _.tap {}, (h) -> h["#{namespace}: #{daemonology[verb].length + 1}"] = advice
            else if _.isArray(advice)
              advice = _.tap {}, (h) -> h["#{namespace}: #{advice[0]}"] = advice[1]
            else
              key = _.keys(advice)[0]
              advice = _.tap {}, (h) -> h["#{namespace}: #{key}"] = advice[key]
          if verb is 'default'
            daemonology.default = advice
          else daemonology[verb].push(advice)

        if pointcut_exprs.length is 1 and (expr = pointcut_exprs[0]) instanceof RegExp
          _.each _.functions(clazz.prototype), (name) ->
            if match_data = name.match(expr)
              daemonize name, match_data
        else
          _.each pointcut_exprs, (expr) ->
            if _.isString(expr) and _.isFunction(clazz.prototype[expr])
              daemonize expr
            else throw 'Specify a pointcut with a single regular expression or a list of strings'

        clazz.__YouAreDaChef

    combinator =
    
      _namespace: null

      default: (pointcut_exprs..., advice) ->
        advise 'default', advice, @_namespace, pointcut_exprs
        combinator

      before: (pointcut_exprs..., advice) ->
        advise 'before', advice, @_namespace, pointcut_exprs
        combinator

      # kestrel
      after: (pointcut_exprs..., advice) ->
        advise 'after', advice, @_namespace, pointcut_exprs
        combinator

      # cardinal combinator
      around: (pointcut_exprs..., advice) ->
        advise 'around', advice, @_namespace, pointcut_exprs
        combinator

      # bluebird
      guard: (pointcut_exprs..., advice) ->
        advise 'guard', advice, @_namespace, pointcut_exprs
        combinator
        
      namespace: (str) ->
        @_namespace = str
        combinator

@YouAreDaChef.inspect ?= (clazz) ->
  clazz.__YouAreDaChef

this