You Are 'Da Chef
===

What is it?
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
            
You can even use regular expressions to specify pointcuts:

    class EnterpriseyLegume
      setId:         (@id)         ->
      setName:       (@name)       ->
      setDepartment: (@department) ->
      setCostCentre: (@costCentre) ->
    
    YouAreDaChef(EnterpriseyLegume)
    
      .around /set(.*)/, (pointcut, match, value) ->
        performTransaction () ->
          writeToLog "#{match[1]}: #{value}"
          pointcut(value)
    

Is it any good?
---

[Yes][y].

[y]: http://news.ycombinator.com/item?id=3067434

I don't believe you!
---

*C'mon, meta-programmed code is read-only. It looks good, but when it comes time to debug or modify anything, it's a nightmare to step through it in the debugger and figure out what's going on.*

That's often the case, but not with YouAreDaChef. Instead of blindly patching methods with wrapper functions, YouAreDaChef stores all of the "advice" functions in a special data structure in the class. You can access it with the `.inspect` method:

    YouAreDaChef.inspect(EnterpriseyLegume)
      => { setCostCentre: 
           { before: [],
             after: [],
             around: [ [Function] ],
             guard: [],
             default: [Function] },
          setDepartment: 
           { before: [],
             after: [],
             around: [ [Function] ],
             guard: [],
             default: [Function] },
          setId: 
           { before: [],
             after: [],
             around: [ [Function] ],
             guard: [],
             default: [Function] },
          setName: 
           { before: [],
             after: [],
             around: [ [Function] ],
             guard: [],
             default: [Function] } }
             
You can inspect each class separately. For each method that has been "advised," the advice is collected in one array for each of the four types of advice. We can see above that four methods have been given `around` advice. The `default` holds the original method's body. In some cases, there is no original method. For example:

    class Animal
      isAnimal: ->
        true
    
    class Dog extends Animal

    YouAreDaChef(Dog)
      .after 'isAnimal', ->
        console?.log "Poor man's debugger says, 'isAnimal was called'"
        
In this case, there is no `isAnimal` method for `Dog`, but YouAreDaChef must not advise `Animal::isAnimal`, so it manufactures a "synthetic" `isAnimal` default for `Dog` that simply calls `super`. You can discover this by inspecting the advice in your debugger. To make debugging even easier, YouAreDaChef also supports *named advice*. Instead of providing an advice function, provide a hash with one or more names and advice functions:

    class Cat extends Animal

    YouAreDaChef(Cat)
      .before 'isAnimal',
        logger: -> 
          console?.log "Poor man's debugger says, 'purr'"
          
    YouAreDaChef.inspect(Cat)
      => { isAnimal: 
           { before: [ { logger: [Function] } ],
             after: [],
             around: [],
             guard: [],
             default: [Function] } }

This makes it much easier to keep track of the advice you have provided. Since you have the advice and can inspect it, you can write unit tests for your advice and debug the advice you have provided more easily. The `.inspect` function does add some code complexity to the YouAreDaChef library, but it makes writing and debugging code written with the YouAreDaChef library much easier.

Can I use it with pure Javascript?
---

[Yes][js].

Can I install it with npm?
---

Yes:

    npm install YouAreDaChef

Will it make me smarter?
---

No, but it can make you *appear* smarter. Just explain that *guard advice is a monad*:
    
    YouAreDaChef(EnterpriseyLegume)
    
      .guard /write(.*)/, ->
        @user.hasPermission('write', match[1])

Guard advice works like a before combination, with the bonus that if it returns something falsely, the pointcut will not be executed. This behaviour is similar to the way ActiveRecord callbacks work.

You can also try making a [cryptic][cry] reference to a [computed][comp], non-local [COMEFROM][cf]. 

[cf]: http://en.wikipedia.org/wiki/COMEFROM
[cry]: http://www.reddit.com/r/programming/comments/m4r4t/aspectoriented_programming_in_coffeescript_with_a/c2yfx6w
[comp]: http://en.wikipedia.org/wiki/Goto#Computed_GOTO

Where can I read more?
---

[Separating Concerns in Coffeescript using Aspect-Oriented Programming][blog]  
[Implementing Garbage Collection in CS/JS with Aspect-Oriented Programming][gc]

[js]: https://github.com/raganwald/YouAreDaChef/blob/master/lib/YouAreDaChef.js
[gc]: https://github.com/raganwald/homoiconic/blob/master/2012/03/garbage_collection_in_coffeescript.md#readme
[blog]: https://github.com/raganwald/homoiconic/blob/master/2011/11/YouAreDaChef.md#readme