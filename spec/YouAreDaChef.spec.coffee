{YouAreDaChef} = require('../lib/YouAreDaChef')
_ = require 'underscore'
require "UnderscoreMatchersForJasmine"

############
# preamble #
############

class Animal
  constructor: (@name) ->

  move: (meters) ->
    @name + " moved #{meters}m."

  felineinate: (a, b) ->
    a + b

class Hippo extends Animal
  move: (meters) ->
    "#{@name} lumbered #{meters}m."

class Snake extends Animal
  move: ->
    super 5

class Horse extends Animal
  move: ->
    super 45

class Pony extends Animal
  move: ->
    super 30

class Cheetah extends Animal

class Monkey extends Animal

class Lion extends Animal

class Tiger extends Animal
  motivate: (meters) ->
    @name + " looks good moving #{meters}m."

class Ass extends Animal

class Assyrian extends Ass

sam = new Snake "Sammy the Python"
tom = new Horse "Tommy the Palomino"
pat = new Pony "Patrick"
ben = new Cheetah "Benny the Cheetah"
poe = new Hippo "Poe the 'Potomous"
moe = new Monkey "Moe the Marauder"
leo = new Lion "Leo the Lionheart"
kat = new Tiger "Kat the Big Cat"
abe = new Assyrian "Abraham"

describe 'YouAreDaChef', ->

  it 'should preserve the order of multiple parameters', ->
  
    first = 'first'
    second = 'second'
  
    YouAreDaChef(Tiger)
      .after 'felineinate', (a, b) ->
        expect( a ).toBe(first)
        expect( b ).toBe(second)
  
    kat.felineinate(first, second)
  
  it 'shouldn\'t introduce a spurious method', ->
  
    class Pig extends Animal
  
    class PotBelliedPig extends Pig
  
    # we introduce advice in the leaf class
    YouAreDaChef(PotBelliedPig).before 'move', ->
      @name = "A Vietnamese Pot-Bellied Pig named #{@name}"
  
    # and then we introduce advice in its parent
    YouAreDaChef(Pig).before 'move', ->
      @name = @name.toUpperCase()
  
    piggie = new Pig('Piggie')
  
    expect(piggie.move(10)).toBe('PIGGIE moved 10m.')
  
    porkie = new PotBelliedPig('Porky')
  
    expect(porkie.move(10)).toBe('A VIETNAMESE POT-BELLIED PIG NAMED PORKY moved 10m.')

  it 'should allow before advice', ->

    expect(tom.move()).toBe('Tommy the Palomino moved 45m.')
    expect(tom.name).toBe("Tommy the Palomino")

    YouAreDaChef(Horse)
      .before 'move', ->
        @name = "Harry the Hoofer"

    expect(tom.move()).toBe('Harry the Hoofer moved 45m.')
    expect(tom.name).toBe("Harry the Hoofer")

  it 'should allow _named_ before advice', ->

    expect(pat.move()).toBe('Patrick moved 30m.')
    expect(pat.name).toBe("Patrick")

    YouAreDaChef(Pony).before 'move',
      rename: ->
        @name = "Harry the Hoofer"

    expect( YouAreDaChef.inspect(Pony).move ).toBeTruthy()
    expect( YouAreDaChef.inspect(Pony).move.before ).toBeAn(Array)
    expect(_.map(YouAreDaChef.inspect(Pony).move.before, _.first) ).toInclude('rename')

    expect(pat.move()).toBe('Harry the Hoofer moved 30m.')
    expect(pat.name).toBe("Harry the Hoofer")

  it 'should allow inspection', ->

    expect( YouAreDaChef.inspect(Horse) ).toEqual(Horse.__YouAreDaChef)

  it 'should allow guard advice', ->

    expect(leo.move(40)).toBe('Leo the Lionheart moved 40m.')
    expect(leo.move(400)).toBe('Leo the Lionheart moved 400m.')

    YouAreDaChef(Lion).guard 'move', (meters) ->
      meters < 100

    expect(leo.move(40)).toBe('Leo the Lionheart moved 40m.')
    expect(leo.move(400)).toBeUndefined()

  it 'should allow after advice', ->

    expect(sam.move()).toBe('Sammy the Python moved 5m.')
    expect(sam.name).toBe("Sammy the Python")

    YouAreDaChef(Snake).after 'move',
      rename: ->
        @name = 'Sly the Slitherer'

    expect( YouAreDaChef.inspect(Snake).move ).toBeTruthy()
    expect( YouAreDaChef.inspect(Snake).move.after ).toBeAn(Array)
    expect( _.map(YouAreDaChef.inspect(Snake).move.after, _.first) ).toInclude('rename')

    expect(sam.move()).toBe('Sammy the Python moved 5m.')
    expect(sam.name).toBe("Sly the Slitherer")

  it 'should allow around advice', ->

    expect(poe.move(2)).toBe('Poe the \'Potomous lumbered 2m.')

    YouAreDaChef(Hippo).around 'move', (pointcut, by_how_much) ->
      pointcut(by_how_much * 2)

    expect(poe.move(2)).toBe('Poe the \'Potomous lumbered 4m.')

  it 'should handle methods not directly defined', ->

    expect(ben.move(7)).toBe('Benny the Cheetah moved 7m.')
    expect(moe.move(7)).toBe('Moe the Marauder moved 7m.')

    YouAreDaChef(Cheetah).around 'move',  (pointcut, by_how_much) ->
      pointcut(by_how_much * 10) + ' That\'s great!'

    expect(ben.move(7)).toBe('Benny the Cheetah moved 70m. That\'s great!')
    expect(moe.move(7)).toBe('Moe the Marauder moved 7m.')

  it 'should allow specifying methods by regular expression', ->

    expect(kat.move(12)).toBe('Kat the Big Cat moved 12m.')
    expect(kat.motivate(12)).toBe('Kat the Big Cat looks good moving 12m.')

    YouAreDaChef(Tiger).around /mo.*/, (pointcut, match, by_how_much) ->
      pointcut(by_how_much * 10)

    expect(kat.move(12)).toBe('Kat the Big Cat moved 120m.')
    expect(kat.motivate(12)).toBe('Kat the Big Cat looks good moving 120m.')

  it 'should allow definition and redefinition of default advice without disrupting the chain', ->

    YouAreDaChef(Ass)
      .before 'move', ->
        @name = 'Rumplestiltskin'

    YouAreDaChef(Assyrian)
      .default 'move', (meters) ->
        "#{@name} lumbered #{meters}m."

    expect(abe.move(5)).toBe("Rumplestiltskin lumbered 5m.")

    YouAreDaChef(Assyrian)
      .default 'move',
        named_advice: (meters) -> "#{@name} sauntered #{meters}m."

    expect(abe.move(5)).toBe("Rumplestiltskin sauntered 5m.")

  it 'should allow defeault definition of a new method without a superclass', ->

    class Mumps

    YouAreDaChef(Mumps)
      .after
        foo: ->
      .default
        foo: ->

    expect(new Mumps().foo()).toBeFalsy()

class Nag extends Horse
class Arabian extends Horse
  mane: -> 'long'

describe 'namespaces', ->

  it 'should namespace anonymous advices', ->

    YouAreDaChef(Nag)
      .namespace('namu')
      .before 'move', ->
        # do nothing

    expect( _.map(YouAreDaChef.inspect(Nag).move.before, _.first) ).toInclude('namu: 1')

  it 'should namespace named advices', ->

    YouAreDaChef(Nag)
      .namespace('namu')
      .before 'move',
        descriptor: ->
          # do nothing

    expect( _.map(YouAreDaChef.inspect(Nag).move.before, _.first) ).toInclude('namu: descriptor')

describe 'bulk advice syntax', ->

  it 'should not regress to prohibit classic definition of a new default', ->

    YouAreDaChef(Nag)
      .namespace('bulk')
      .default 'baz', -> 'baz'


  it 'should support default advice', ->

    n = new Nag 'en'
    YouAreDaChef(Nag)
      .namespace('bulk')
      .default
        foo: -> 'f.u.'
        bar: -> 'barre'

    expect(n).toRespondTo('foo', 'bar')
    expect(n.foo()).toEqual('f.u.')

  it 'should support before advice', ->

    arab = new Arabian 'annoy'
    YouAreDaChef(Arabian)
      .namespace('bulk')
      .before
        mane: ->
          @maned = true

    expect(arab.maned).toBeFalsy()
    expect( arab.mane() ).toEqual('long')
    expect(arab.maned).toBeTruthy()

describe 'fluent syntax', ->

  beforeEach ->

    class @Foo
    class @Bar

    @foo = new @Foo()
    @bar = new @Bar()

  it 'should support a single class', ->

    expect(@foo).not.toRespondTo('something')

    YouAreDaChef
      .for(@Foo)
        .default
          something: ->

    expect(@foo).toRespondTo('something')

  it 'should support multiple classes', ->

    expect(@foo).not.toRespondTo('something')
    expect(@bar).not.toRespondTo('something')

    YouAreDaChef
      .for(@Foo, @Bar)
        .default
          something: ->

    expect(@foo).toRespondTo('something')
    expect(@bar).toRespondTo('something')

  it 'should support changing classes', ->

    expect(@foo).not.toRespondTo('something', 'awful')
    expect(@bar).not.toRespondTo('something', 'awful')

    YouAreDaChef
      .for(@Foo)
        .default
          something: ->
      .for(@Bar)
        .default
          awful: ->

    expect(@foo).toRespondTo('something')
    expect(@foo).not.toRespondTo('awful')
    expect(@bar).not.toRespondTo('something')
    expect(@bar).toRespondTo('awful')

  it 'should preserve namespaces', ->

    YouAreDaChef
      .namespace('baz')
      .for(@Foo)
        .default
          something: ->
      .for(@Bar)
        .default
          awful: ->

    expect(YouAreDaChef.inspect(@Foo).something.default[1][0]).toBe('baz: 2')
    expect(YouAreDaChef.inspect(@Bar).awful.default[1][0]).toBe('baz: 2')
