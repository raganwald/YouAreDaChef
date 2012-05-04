_ = require 'underscore'

_.defaults this,
  YouAreDaChef: (clazzes...) ->

    advise = (verb, advice, pointcut_exprs) ->
      _.each clazzes, (clazz) ->
        daemonize = (name, inject = []) ->
          daemonology = (clazz.__YouAreDaChef ?= {})[name] ?= {}
          _.defaults daemonology,
            before: []
            after: []
            around: []
            guard: []
          # TODO: Consider splitting these so that it's obvious when doing before and after
          #       during debugging
          clazz.prototype["before_#{name}_daemon"] ?= (args...) ->
            daemon_args = inject.concat args
            # execute specific daemons for side-effects
            for daemon in daemonology.before.reverse()
              if _.isFunction(daemon)
                daemon.apply(this, daemon_args)
              else if _.isArray(daemon)
                daemon[1].apply(this, daemon_args)
              else for name, advice of daemon
                advice.apply(this, args)
            # try a super-daemon if available
            clazz.__super__?["before_#{name}_daemon"]?.apply(this, args)
          clazz.prototype["after_#{name}_daemon"] ?= (args...) ->
            daemon_args = inject.concat args
            # try a super-daemon if available
            clazz.__super__?["after_#{name}_daemon"]?.apply(this, args)
            # execute specific daemons for side-effects
            for daemon in daemonology.after
              if _.isFunction(daemon)
                daemon.apply(this, daemon_args)
              else if _.isArray(daemon)
                daemon[1].apply(this, daemon_args)
              else for name, advice of daemon
                advice.apply(this, daemon_args)
          clazz.prototype["around_#{name}_daemon"] ?= (args...) ->
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
              else for name, advice of daemon
                fn_list.unshift advice

            fn = _.reduce fn_list, (acc, advice) ->
              (args...) -> advice.call(this, acc, daemon_args...)
            , (args...) => daemonology.default.apply(this, args)

            fn.apply(this, args)

          clazz.prototype["guard_#{name}_daemon"] ?= (args...) ->
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
              else for name, advice of daemon
                return false unless advice.apply(this, daemon_args)

            true

          # FIXME: Support injecting match data

          # this patches the original method to call advices and pass match data
          unless clazz.prototype[name]? and daemonology.default?
            if _.include(_.keys(clazz.prototype), name)
              daemonology.default = clazz.prototype[name]
            else if clazz.__super__?
              daemonology.default = (args...) ->
                clazz.__super__[name].apply(this, args)
            else
              throw 'No method or superclass given ' + name
            clazz.prototype[name] = (args...) ->
              if clazz.prototype["guard_#{name}_daemon"].apply(this, args)
                clazz.prototype["before_#{name}_daemon"].apply(this, args)
                _.tap clazz.prototype["around_#{name}_daemon"].apply(this, args), (retv) =>
                  clazz.prototype["after_#{name}_daemon"].apply(this, args)
                  
          # Add the advice to the appropriate list
          daemonology[verb].push(advice)
          
        if pointcut_exprs.length is 1 and (expr = pointcut_exprs[0]) instanceof RegExp
          _.each _.functions(clazz.prototype), (name) ->
            if match_data = name.match(expr)
              daemonize name, match_data
        else
          _.each pointcut_exprs, (expr) ->
            if _.isString(expr) and _.isFunction(clazz.prototype[expr])
              daemonize expr
            else throw 'Specify a pointcut witha single regular expression or a list of strings'

        clazz.__YouAreDaChef

    combinator =

      before: (pointcut_exprs..., advice) ->
        advise 'before', advice, pointcut_exprs
        combinator

      # kestrel
      after: (pointcut_exprs..., advice) ->
        advise 'after', advice, pointcut_exprs
        combinator

      # cardinal combinator
      around: (pointcut_exprs..., advice) ->
        advise 'around', advice, pointcut_exprs
        combinator

      # bluebird
      guard: (pointcut_exprs..., advice) ->
        advise 'guard', advice, pointcut_exprs
        combinator

@YouAreDaChef.inspect ?= (clazz) ->
  clazz.__YouAreDaChef

this