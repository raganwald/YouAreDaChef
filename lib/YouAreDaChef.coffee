_ = require 'underscore'

_.defaults this,
  YouAreDaChef: (clazzes...) ->

    pointcuts = (pointcut_exprs) ->
      _.tap {}, (cuts) ->
        _.each pointcut_exprs, (name) ->
          _.each clazzes, (clazz) ->
            if _.isFunction(clazz.prototype[name])
              cuts[name] =
                clazz: clazz
                pointcut: clazz.prototype[name]

    combinator =

      before: (pointcut_exprs..., advice) ->
        _.each pointcuts(pointcut_exprs), ({clazz, pointcut}, name) ->
          clazz.prototype[name] = (args...) ->
            advice.apply(this, args)
            pointcut.apply(this, args)
        combinator

      # kestrel
      after: (pointcut_exprs..., advice) ->
        _.each pointcuts(pointcut_exprs), ({clazz, pointcut}, name) ->
          clazz.prototype[name] = (args...) ->
            _.tap pointcut.apply(this, args), =>
              advice.apply(this, args)
        combinator

      # cardinal combinator
      around: (pointcut_exprs..., advice) ->
        _.each pointcuts(pointcut_exprs), ({clazz, pointcut}, name) ->
          clazz.prototype[name] = (args...) ->
            bound_pointcut = (args2...) =>
              pointcut.apply(this, args2)
            advice.call(this, bound_pointcut, args...)
        combinator

      # bluebird
      guard: (pointcut_exprs..., advice) ->
        _.each pointcuts(pointcut_exprs), ({clazz, pointcut}, name) ->
          clazz.prototype[name] = (args...) ->
            pointcut.apply(this, args) if advice.apply(this, args)
        combinator