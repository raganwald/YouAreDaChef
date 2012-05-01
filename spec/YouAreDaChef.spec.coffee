YouAreDaChef = require('../lib/YouAreDaChef.coffee').YouAreDaChef
_ = require 'underscore'

############
# preamble #
############

class Animal
  constructor: (@name) ->

  move: (meters) ->
    @name + " moved #{meters}m."

class Hippo extends Animal
  move: (meters) ->
    @name + " lumbered #{meters}m."

class Snake extends Animal
  move: ->
    super 5

class Horse extends Animal
  move: ->
    super 45

class Cheetah extends Animal

class Monkey extends Animal

class Lion extends Animal

class Tiger extends Animal
  movie: (meters) ->
    @name + " looks good moving #{meters}m."

sam = new Snake "Sammy the Python"
tom = new Horse "Tommy the Palomino"
ben = new Cheetah "Benny the Cheetah"
poe = new Hippo "Poe the 'Potomous"
moe = new Monkey "Moe the Marauder"
leo = new Lion "Leo the Lionheart"
kat = new Tiger "Kat the Big Cat"

describe 'YouAreDaChef', ->

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

    YouAreDaChef(Horse).before 'move', ->
      @name = "Harry the Hoofer"

    expect(tom.move()).toBe('Harry the Hoofer moved 45m.')
    expect(tom.name).toBe("Harry the Hoofer")

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

    YouAreDaChef(Snake).after 'move', ->
      @name = 'Sly the Slitherer'

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

    console?.log

    expect(kat.move(12)).toBe('Kat the Big Cat moved 12m.')
    expect(kat.movie(12)).toBe('Kat the Big Cat looks good moving 12m.')

    YouAreDaChef(Tiger).around /mo.*/, (pointcut, match, by_how_much) ->
      pointcut(by_how_much * 10)

    expect(kat.move(12)).toBe('Kat the Big Cat moved 120m.')
    expect(kat.movie(12)).toBe('Kat the Big Cat looks good moving 120m.')