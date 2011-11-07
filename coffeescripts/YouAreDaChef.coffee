_ = require 'underscore'
YouAreDaChef = this
_.defaults YouAreDaChef,
  advise: (clazzes...) ->
    advisor =
      before: (method_names..., before_fn) ->
        _.each method_names, (name) ->
          _.each clazzes, (clazz) ->
            if _.isFunction(clazz.prototype[name])
              old_fn = clazz.prototype[name]
              clazz.prototype[name] = (args...) ->
                before_fn.apply(this, args)
                old_fn.call(this, args)
        advisor

      after: (method_names..., after_fn) ->
        _.each method_names, (name) ->
          _.each clazzes, (clazz) ->
            if _.isFunction(clazz.prototype[name])
              old_fn = clazz.prototype[name]
              clazz.prototype[name] = (args...) ->
                _.tap old_fn.apply(this, args), =>
                  after_fn.apply(this, args)
        advisor

      around: (method_names..., around_fn) ->
        _.each method_names, (name) ->
          _.each clazzes, (clazz) ->
            if _.isFunction(clazz.prototype[name])
              unbound_fn = clazz.prototype[name]
              clazz.prototype[name] = (args...) ->
                bound_fn = (args2...) =>
                  unbound_fn.apply(this, args2)
                around_fn.call(this, bound_fn, args...)
        advisor