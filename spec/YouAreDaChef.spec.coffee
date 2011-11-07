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
  move: ->
    super 70

sam = new Snake "Sammy the Python"
tom = new Horse "Tommy the Palomino"
ben = new Cheetah "Benny the Cheetah"
poe = new Hippo "Poe the 'Potomous"

describe 'YouAreDaChef', ->

  it 'should not affect classes uless explicitly run', ->
    expect(ben.move()).toBe('Benny the Cheetah moved 70m.')
    expect(ben.name).toBe("Benny the Cheetah")

  it 'should allow before advice', ->
    YouAreDaChef.advise(Horse).before 'move', ->
      @name = "Harry the Hoofer"
    expect(tom.move()).toBe('Harry the Hoofer moved 45m.') # name has changed
    expect(tom.name).toBe("Harry the Hoofer") # name has changed now

  it 'should allow after advice', ->
    YouAreDaChef.advise(Snake).after 'move', ->
      @name = 'Sly the Slitherer'
    expect(sam.move()).toBe('Sammy the Python moved 5m.') # name has not changed
    expect(sam.name).toBe("Sly the Slitherer") # name has changed now

  it 'should allow around advice', ->
    YouAreDaChef.advise(Hippo).around 'move', (fn, by_how_much) ->
      console?.log arguments
      fn(by_how_much * 2)
    expect(poe.move(2)).toBe('Poe the \'Potomous lumbered 4m.') # name has not changed