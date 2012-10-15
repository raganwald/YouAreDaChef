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
    
There must be more to it than that
---

Yes there is, there's a [Quick Start Guide][qsg] and a discussion of the [special sauce], YouAreDaChef's inheritance model.

[qsg]: https://github.com/raganwald/YouAreDaChef/blob/master/docs/quick.md
[special sauce]: https://github.com/raganwald/YouAreDaChef/blob/master/docs/special-sauce.md


Is it any good?
---

[Yes][y].

[y]: http://news.ycombinator.com/item?id=3067434

I don't believe you!
---

*C'mon, meta-programmed code is read-only. It looks good, but when it comes time to debug or modify anything, it's a nightmare to step through it in the debugger and figure out what's going on.*

That's often the case, but starting with version 1.0, YouAreDaChef is designed to make code that's easy to write, not just easy to read. Instead of blindly patching methods with wrapper functions, YouAreDaChef stores all of the "advice" functions in a special data structure in the class. You can inspect each class separately. You can provide names for the advice you add to methods, which makes it easier to keep track of the advice you have provided. Since you have the advice and can inspect it, you can write unit tests for your advice and debug the advice you have provided more easily. The `.inspect` function does add some code complexity to the YouAreDaChef library, but it makes writing and debugging code written with the YouAreDaChef library much easier.

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
    
      .when /write(.*)/, ->
        @user.hasPermission('write', match[1])

Guard advice works like a before combination, with the bonus that if it returns something falsely, the pointcut will not be executed. This behaviour is similar to the way ActiveRecord callbacks work.

You can also try making a [cryptic][cry] reference to a [computed][comp], non-local [COMEFROM][cf]. 

[cf]: http://en.wikipedia.org/wiki/COMEFROM
[cry]: http://www.reddit.com/r/programming/comments/m4r4t/aspectoriented_programming_in_coffeescript_with_a/c2yfx6w
[comp]: http://en.wikipedia.org/wiki/Goto#Computed_GOTO

I might not need all of its awesomeness
---

Have a look at [method-combinators].

[method-combinators]: https://github.com/raganwald/method-combinators

Where can I read more?
---

[Quick Start Guide][qsg]  
[Separating Concerns in CoffeeScript using Aspect-Oriented Programming][blog]  
[Implementing Garbage Collection in CS/JS with Aspect-Oriented Programming][gc]  

[js]: https://github.com/raganwald/YouAreDaChef/blob/master/lib/YouAreDaChef.js
[gc]: https://github.com/raganwald/homoiconic/blob/master/2012/03/garbage_collection_in_coffeescript.md#readme
[blog]: https://github.com/raganwald/homoiconic/blob/master/2011/11/YouAreDaChef.md#readme

In memoriam
---

YouAreDaChef's method advice is loosely based on Lisp Flavors, specifically the inheritance of `before` and `after` advice plus the overriding of `default` advice (called `daemon` in Flavors). [Dan Weinreb](https://en.wikipedia.org/wiki/Daniel_Weinreb) (d. 2012) played an important role in the development of Lisp. He is missed by many.

post scriptum
-------------

I'm writing a book called [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto). Check it out!

Et cetera
---

YouAreDaChef was created by [Reg "raganwald" Braithwaite][raganwald]. It is available under the terms of the [MIT License][lic].

[raganwald]: http://braythwayt.com
[lic]: https://github.com/raganwald/YouAreDaChef/blob/master/license.md