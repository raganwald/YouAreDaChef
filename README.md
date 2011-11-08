You Are 'Da Chef
===

What and Why
---

This library adds `before`, `after`, `around`, and `guard` method combinations to underscore.js projects, in much the same style as the Common Lisp Object System or Ruby on Rails controllers. With method combinations, you can easily separate concerns.

For example:

    class Wumpus
        roar: ->
            # ...
        run: ->
            #...

    class Hunter
        draw: (bow) ->
            # ...
        quiver: ->
            # ...
        run: ->
            #...

    hydrate = (object) ->
        # code that hydrates the object from storage

    YouAreDaChef(Wumpus, Hunter)
    
        .before 'roar', 'draw', 'run', ->
            hydrate(this)
            
        .after 'roar', 'draw', ->
            @trigger 'action'
            
        .after 'run', ->
            @trigger 'move'

Is it any good?
---

Yes.

Where can I read more?
---

[Aspect-Oriented Programming in Coffeescript using Combinator Birds](https://github.com/raganwald/homoiconic/blob/master/2011/11/YouAreDaChef.md#readme)