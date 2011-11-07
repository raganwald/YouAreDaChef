YouAreDaChef = require '../coffeescripts/YouAreDaChef.coffee'
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

sam = new Snake "Sammy the Python"
tom = new Horse "Tommy the Palomino"
ben = new Cheetah "Benny the Cheetah"
poe = new Hippo "Poe the 'Potomous"

describe 'YouAreDaChef', ->

  it 'should allow before advice', ->

    expect(tom.move()).toBe('Tommy the Palomino moved 45m.')
    expect(tom.name).toBe("Tommy the Palomino")

    YouAreDaChef.advise(Horse).before 'move', ->
      @name = "Harry the Hoofer"

    expect(tom.move()).toBe('Harry the Hoofer moved 45m.')
    expect(tom.name).toBe("Harry the Hoofer")

  it 'should allow after advice', ->

    expect(sam.move()).toBe('Sammy the Python moved 5m.')
    expect(sam.name).toBe("Sammy the Python")

    YouAreDaChef.advise(Snake).after 'move', ->
      @name = 'Sly the Slitherer'

    expect(sam.move()).toBe('Sammy the Python moved 5m.')
    expect(sam.name).toBe("Sly the Slitherer")

  it 'should allow around advice', ->

    expect(poe.move(2)).toBe('Poe the \'Potomous lumbered 2m.')

    YouAreDaChef.advise(Hippo).around 'move', (fn, by_how_much) ->
      fn(by_how_much * 2)

    expect(poe.move(2)).toBe('Poe the \'Potomous lumbered 4m.')

  it 'should handle methods not directly defined', ->

    expect(ben.move(7)).toBe('Benny the Cheetah moved 7m.')

    YouAreDaChef.advise(Cheetah).around 'move',  (fn, by_how_much) ->
      fn(by_how_much * 10) + ' That\'s great!'

    expect(ben.move(7)).toBe('Benny the Cheetah moved 70m. That\'s great!')

