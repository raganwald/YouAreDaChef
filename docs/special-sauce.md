YouAreDaChef's "Special Sauce"
==============================

YouAreDaChef uses *three* pieces of code to separate advice from methods. The advice is one chunk:

```coffeescript
triggers = (eventStrings...) ->
             for eventString in eventStrings
               @trigger(eventString)

displaysWait = do ->
                 waitLevel = 0
                 (yield) ->
                   someDOMElement.show() if (waitLevel += 1) > 0
                   yield()
                   someDOMElement.hide() if (waitLevel -= 1) <= 0
```

The methods are another:

```coffeescript
class SomeExampleModel

  setHeavyweightProperty: (property, value) ->
    # set some property in a complicated way
    
  recalculate: ->
    # Do something that takes a long time
```

And finally, YouAreDaChef binds them together in a third:

```coffeescript
YouAreDaChef

  .clazz(SomeExampleModel)
  
    .method('setHeavyweightProperty', 'recalculate')
      .after triggers('cache:dirty')
      
    .method('recalculate')
      .around displaysWait
```

Having the binding in a separate chunk of code does make a few things easy. What happens if you omit the third chunk of code? If you are careful to make the YouAreDaChef bindings the only dependency between the advice and the method bodies, you have decoupled the advice from the methods.

What does this make easy? Well, for one thing, it makes testing easy. You don't need your tests to elaborately mock up a lot of authorization code to appease the authorization advice, you simply don't bind it when you're unit testing the base functionality, and you bind it when you're integration testing the whole thing.

YouAreDaChef's decoupling makes writing tests easy by decoupling code so that you can test one responsibility at a time.

YouAreDaChef does allow you to break things into three pieces, but you can also put them back into two pieces. Here's a way to organize the code in two pieces:

```coffeescript

# YouAreDaChef I

triggers = (eventStrings...) ->
             for eventString in eventStrings
               @trigger(eventString)
               
YouAreDaChef
  .clazz(SomeExampleModel)
    .method('setHeavyweightProperty', 'recalculate')
      .after triggers('cache:dirty')

# YouAreDaChef II

class SomeExampleModel

  setHeavyweightProperty: (property, value) ->
    # set some property in a complicated way
    
  recalculate: ->
    # Do something that takes a long time
```

We've put the YouAreDaChef code binding the advice to the methods with the implementation of the advice. This makes it easy to look at a particular concern--like managing a cache--and know everything about its behaviour. The YouAreDaChef approach makes working with cross-cutting concerns easy: You never have to go hunting through the app to find out what classes and methods are advised by the concern.

What is YouAreDaChef's special sauce?
-------------------------------------

YouAreDaChef does something else as well. YouAreDaChef treats methods as having advice and a *default* body. So in the `triggers` example above, `triggers` is *after advice* and the body of `recalculate` is the *default body*. If there is no inheritance involved, it works exactly like the [method combinators] module. But when we have inheritance, YouAreDaChef has a more complex model than JavaScript's baked-in protocol. With YouAreDaChef, the before, after, around, and guard advice is always inherited. Only the default body is overridden. Here's a contrived example:

[method combinators]: http://github.com/raganwald/method-combinators

```coffeescript
class ShowyModel extends SomeExampleModel
               
YouAreDaChef
  .clazz(ShowyModel)
    .method('setHeavyweightProperty')
      .around displaysWait
```

This code says that a `ShowyModel` extends a `SomeExampleModel`, obviously. It also says that the `setHeavyweightProperty` of a `ShowyModel` has some around advice, `displaysWait`. But it also inherits `SomeExampleModel`'s default method body and its after advice of `triggers('cache:dirty')`. In YouAreDaChef, advice is additive.

We could also change the default body without changing the after advice, like this:

```coffeescript
class DifferentPropertyImplementationModel extends SomeExampleModel
               
YouAreDaChef
  .clazz(DifferentPropertyImplementationModel)
    .method('setHeavyweightProperty')
      .default (property, value) ->
        # set some property in a different way
```

Our `DifferentPropertyImplementationModel` inherits the `after` advice from `SomeExampleModel` but overrides the default body. Default bodies are not additive, they override.

This style of inheritance looks very weird if you think in terms of the implementation. If you try to figure out what YouAreDaChef is doing rather than what its declarations mean, it's a lot. But if you accept the abstraction at face value, it's very simple: If you declare that `triggers('cache:dirty')` happens after the `setHeavyweightProperty` method of `SomeExampleModel` is invoked, well, doesn't that obviously mean it happens after the `setHeavyweightProperty` methods of `ShowyModel` or `DifferentPropertyImplementationModel` are invoked? They're `SomeExampleModel`s too!

If it didn't, we'd have to redeclare all of our advice every time we subclassed. And worse, it would be a maintenance nightmare. if you add a new piece of advice to `SomeExampleModel`, can you be sure you remembered to add it to all of its subclasses that might override its methods?

This is YouAreDaChef's special sauce: It makes working with inheritance easy by decoupling advice inheritance from method body inheritance.

p.s. This isn't a new idea: It's based on Lisp Flavors, which begat New Flavors, and is now part of the Common Lisp Object Model.