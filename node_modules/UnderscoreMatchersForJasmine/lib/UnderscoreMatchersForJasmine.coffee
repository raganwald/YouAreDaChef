_ = require('underscore') unless _?

invoke = (method_name, args...) ->
  if _.isFunction(@actual[method_name])
    @actual[method_name].apply(@actual, args)
  else
    args.unshift(@actual)
    _[method_name].apply(@actual, args)

beforeEach ->
  @addMatchers
    toBeEmpty: ->
      invoke.call(this, 'isEmpty')

    toInclude: (items...) ->
      _(items).all (item) =>
        invoke.call(this, 'include', item)

    toIncludeAny: (items...) ->
      _(items).any (item) =>
        invoke.call(this, 'include', item)

    toBeCompact: ->
      elements = invoke.call(this, 'map', _.identity)
      _.isEqual elements, _.compact(elements)

    toBeUnique: ->
      elements = invoke.call(this, 'map', _.identity)
      _.isEqual elements, _.uniq(elements)

    toRespondTo: (methods...)->
      _.all methods, (method) =>
        _.isFunction(@actual[method])

    toRespondToAny: (methods...)->
      _.any methods, (method) =>
        _.isFunction(@actual[method])

    toHave: (attrs...) ->
      _.all attrs, (attr) =>
        @actual.has(attr)

    toHaveAny: (attrs...) ->
      _.any attrs, (attr) =>
        @actual.has(attr)

    toBeAnInstanceOf: (clazz) ->
      @actual instanceof clazz

    toBeA: (clazz) ->
      @actual instanceof clazz

    toBeAn: (clazz) ->
      @actual instanceof clazz
