_ = require 'underscore'
_.defaults this,
  YouAreDaChef: (clazzes...) ->
    combinator =

      before: (method_names..., advice) ->
        _.each method_names, (name) ->
          _.each clazzes, (clazz) ->
            if _.isFunction(clazz.prototype[name])
              pointcut = clazz.prototype[name]
              clazz.prototype[name] = (args...) ->
                advice.apply(this, args)
                pointcut.apply(this, args)
        combinator

      # kestrel
      after: (method_names..., advice) ->
        _.each method_names, (name) ->
          _.each clazzes, (clazz) ->
            if _.isFunction(clazz.prototype[name])
              pointcut = clazz.prototype[name]
              clazz.prototype[name] = (args...) ->
                _.tap pointcut.apply(this, args), =>
                  advice.apply(this, args)
        combinator

      # cardinal combinator
      around: (method_names..., advice) ->
        _.each method_names, (name) ->
          _.each clazzes, (clazz) ->
            if _.isFunction(clazz.prototype[name])
              pointcut = clazz.prototype[name]
              clazz.prototype[name] = (args...) ->
                bound_pointcut = (args2...) =>
                  pointcut.apply(this, args2)
                advice.call(this, bound_pointcut, args...)
        combinator

      # bluebird
      guard: (method_names..., advice) ->
        _.each method_names, (name) ->
          _.each clazzes, (clazz) ->
            if _.isFunction(clazz.prototype[name])
              pointcut = clazz.prototype[name]
              clazz.prototype[name] = (args...) ->
                pointcut.apply(this, args) if advice.apply(this, args)
        combinator