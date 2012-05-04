_ = require 'underscore'

_.defaults this,
  YouAreDaChef: (clazzes...) ->

    advise = (verb, advice, pointcut_exprs) ->
      _.each clazzes, (clazz) ->
        daemonize = (name) ->
          daemonology = (clazz.__YouAreDaChef ?= {})[name] ?= {}
          _.defaults daemonology,
            before: []
            after: []
            around: []
            guard: []
          # TODO: Consider splitting these so that it's obvious when doing before and after
          #       during debugging
          clazz.prototype["before_#{name}_daemon"] ?= (args...) ->
            # execute specific daemons for side-effects
            for daemon in daemonology.before
              if _.isFunction(daemon)
                daemon.apply(this, args)
              else if _.isArray(daemon)
                daemon[1].apply(this, args)
              else for name, advice of daemon
                advice.apply(this, args)
            # try a super-daemon if available
            clazz.__super__?["before_#{name}_daemon"]?.apply(this, args)
          clazz.prototype["after_#{name}_daemon"] ?= (args...) ->
            # try a super-daemon if available
            clazz.__super__?["after_#{name}_daemon"]?.apply(this, args)
            # execute specific daemons for side-effects
            for daemon in daemonology.after.reverse()
              if _.isFunction(daemon)
                daemon.apply(this, args)
              else if _.isArray(daemon)
                daemon[1].apply(this, args)
              else for name, advice of daemon
                advice.apply(this, args)
          # FIXME: around advice
          # FIXME: guard advice
          # FIXME: Support injecting match data
          #
          # patch method to call advices
          unless clazz.prototype[name]? and daemonology.default?
            if _.include(_.keys(clazz.prototype), name)
              daemonology.default = clazz.prototype[name]
            else if clazz.__super__?
              daemonology.default = (args...) ->
                clazz.__super__[name].apply(this, args)
            else
              throw 'No method or superclass given ' + name
            clazz.prototype[name] = (args...) ->
              clazz.prototype["before_#{name}_daemon"]?.apply(this, args)
              _.tap daemonology.default.apply(this, args), (retv) =>
                clazz.prototype["after_#{name}_daemon"]?.call(this, retv, args...)
          daemonology[verb].push(advice)

        _.each pointcut_exprs, (expr) ->
          if _.isString(expr) and _.isFunction(clazz.prototype[expr])
            daemonize(expr)
          else if expr instanceof RegExp
            _.each _.functions(clazz.prototype), (name) ->
              daemonize(name) if name.match(expr)

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