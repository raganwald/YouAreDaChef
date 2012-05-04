require './../lib/UnderscoreMatchersForJasmine'

describe "toBeEmpty", ->

  it 'should work for arrays', ->

    expect([]).toBeEmpty()
    expect([1]).not.toBeEmpty()

  if Backbone?

    it 'should work for backbone collections', ->
      c = new Backbone.Collection()
      expect(c).toBeEmpty()
      c.add
        foo: 'bar'

      expect(c).not.toBeEmpty()


describe "toInclude", ->

  it 'should work for arrays', ->

    expect([]).not.toInclude('s')
    expect(['s', 'n', 'a', 'f', 'u']).toInclude('f', 'a', 'n')
    expect(['s', 'n', 'a', 'f', 'u']).not.toInclude('p', 'a', 'n')
    expect(['s', 'n', 'a', 'f', 'u']).not.toInclude('f', 'a', 'x')

  if Backbone?

    it 'should work for backbone collections', ->
      c = new Backbone.Collection()
      [s, n, a, f, u, p, x] = [new Backbone.Model(), new Backbone.Model(), new Backbone.Model(), new Backbone.Model(), new Backbone.Model(), new Backbone.Model(), new Backbone.Model()]
      expect(c).not.toInclude(s)

      c.add [s, n, a, f, u]

      expect(c).toInclude f, a, n
      expect(c).not.toInclude p, a, n
      expect(c).not.toInclude f, a, x


describe "toIncludeAny", ->

  it 'should work for arrays', ->

    expect([]).not.toIncludeAny('s')
    expect(['s', 'n', 'a', 'f', 'u']).toIncludeAny('f', 'a', 'n')
    expect(['s', 'n', 'a', 'f', 'u']).toIncludeAny('p', 'a', 'n')
    expect(['s', 'n', 'a', 'f', 'u']).toIncludeAny('f', 'a', 'x')
    expect(['s', 'n', 'a', 'f', 'u']).not.toIncludeAny('p', 'x')

  if Backbone?

    it 'should work for backbone collections', ->
      c = new Backbone.Collection()
      [s, n, a, f, u, p, x] = [new Backbone.Model(), new Backbone.Model(), new Backbone.Model(), new Backbone.Model(), new Backbone.Model(), new Backbone.Model(), new Backbone.Model()]
      expect(c).not.toIncludeAny(s)

      c.add [s, n, a, f, u]

      expect(c).toIncludeAny f, a, n
      expect(c).toIncludeAny p, a, n
      expect(c).toIncludeAny f, a, x
      expect(c).not.toIncludeAny p, x

describe "toBeCompact", ->

  undef = null
  ((_) -> undef = _)()
  expect(undef).toBeUndefined()

  it 'should work for arrays', ->

    expect([]).toBeCompact()
    expect(['s', 'n', 'a', 'f', 'u']).toBeCompact()
    expect(['s', 'n', 'a', false, 'u']).not.toBeCompact()
    expect(['s', null, 'a', 'f', 'u']).not.toBeCompact()
    expect(['s', 'n', 'a', 'f', undef]).not.toBeCompact()

describe "toBeUnique", ->

  undef = null
  ((_) -> undef = _)()
  expect(undef).toBeUndefined()

  it 'should work for arrays', ->

    expect([]).toBeUnique()
    expect(['s', 'n', 'a', 'f', 'u']).toBeUnique()
    expect(['s', 'n', 'a', 'a', 'u']).not.toBeUnique()
    expect(['s', 'f', 'u', 'f', 'u']).not.toBeUnique()

describe 'toRespondTo', ->

  it 'should work for a single function', ->

    expect([]).toRespondTo('push')
    expect([]).toRespondTo('pop')
    expect([]).not.toRespondTo('pizzle')

  it 'should have all semantics for multiple functions', ->

    expect([]).toRespondTo('push','pop')
    expect([]).not.toRespondTo('push','pop','pizzle')

describe 'toRespondToAny', ->

  it 'should work for a single function', ->

    expect([]).toRespondToAny('push')
    expect([]).toRespondToAny('pop')
    expect([]).not.toRespondToAny('pizzle')

  it 'should have any semantics for multiple functions', ->

    expect([]).toRespondToAny('push','pop', 'pizzle')
    expect([]).not.toRespondTo('pasta','salad','pizzle')


describe 'toBeAnInstanceOf', ->

  it 'should work with basic JS objects', ->
    C = () ->
    D = () ->

    c = new C()
    expect(c).toBeAnInstanceOf(Object)
    expect(c).toBeAnInstanceOf(C)
    expect(c).not.toBeAnInstanceOf(D)

    expect(c).toBeA(Object)
    expect(c).toBeA(C)
    expect(c).not.toBeA(D)

    expect(c).toBeAn(Object)
    expect(c).toBeAn(C)
    expect(c).not.toBeAn(D)

  if Backbone?

    it 'should work with Backbone classes as well', ->
      B = Backbone.Model.extend()
      C = B.extend()
      D = Backbone.Model.extend()

      c = new C()
      expect(c).toBeAnInstanceOf(B)
      expect(c).toBeAnInstanceOf(C)
      expect(c).not.toBeAnInstanceOf(D)

      expect(c).toBeA(B)
      expect(c).toBeA(C)
      expect(c).not.toBeA(D)

      expect(c).toBeAn(B)
      expect(c).toBeAn(C)
      expect(c).not.toBeAn(D)

if Backbone?

  describe 'toHave', ->

    it 'should report whether a property is set with something truthy', ->
      model = new Backbone.Model
        foo: 'fu'
      expect(model).toHave('foo')
      expect(model).not.toHave('bar')

    it 'should have the same semantics as .has for falsy-ish values', ->
      model = new Backbone.Model
        false: false
        null: null
        zero: 0
        empty_array: []
        empty_string: ''
        undefined: undefined
      _.each model.attributes, (value, key) ->
        if model.has(key)
          expect(model).toHave(key)
        else
          expect(model).not.toHave(key)

    it 'should be compatible with unset', ->
      model = new Backbone.Model
        foo: 'fu'
      expect(model).toHave('foo')
      model.unset('foo')
      expect(model).not.toHave('foo')

    it 'should have all semantics', ->
      model = new Backbone.Model
        foo: 'fu'
        bar: 'bar'
      expect(model).toHave('foo', 'bar')
      expect(model).not.toHave('snafu', 'bar')

  describe 'toHaveAny', ->

    it 'should report whether a property is set with something truthy', ->
      model = new Backbone.Model
        foo: 'fu'
      expect(model).toHaveAny('foo')
      expect(model).not.toHaveAny('bar')

    it 'should have the same semantics as .has for falsy-ish values', ->
      model = new Backbone.Model
        false: false
        null: null
        zero: 0
        empty_array: []
        empty_string: ''
        undefined: undefined
      _.each model.attributes, (value, key) ->
        if model.has(key)
          expect(model).toHaveAny(key)
        else
          expect(model).not.toHaveAny(key)

    it 'should be compatible with unset', ->
      model = new Backbone.Model
        foo: 'fu'
      expect(model).toHaveAny('foo')
      model.unset('foo')
      expect(model).not.toHaveAny('foo')

    it 'should have any semantics', ->
      model = new Backbone.Model
        foo: 'fu'
        bar: 'bar'
      expect(model).toHaveAny('foo', 'bar')
      expect(model).toHaveAny('snafu', 'bar')
      expect(model).not.toHaveAny('snafu', 'fubar')
