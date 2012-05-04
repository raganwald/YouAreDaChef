Underscore Matchers for Jasmine
===

UnderscoreMatchersForJasmine adds a series of matchers for [Jasmine][1]-based Javascript/[Coffeescript][2] testing based on [Underscore][_] methods. Example:

    expect(snafu).toInclude('s', 'n', 'a')
    
    // if snafu is an array, this is equivalent to:
    expect(
      _(snafu).include('s') && _(snafu).include('n') && _(snafu).include('a')
    ).toBeTruthy()

    // if snafu is a Backbone.js collection, this is equivalent to:
    expect(
      snafu.include('s') && snafu.include('n') && snafu.include('a')
    ).toBeTruthy()
    
[1]: https://github.com/pivotal/jasmine
[2]: https://github.com/jashkenas/coffee-script
[_]: http://documentcloud.github.com/underscore/

That makes your tests easy to read, for example:

    $ ->
      describe 'States and StateMachines', ->
        it 'should associate states with a state machine and the state machine with its states', ->
          engine_status = new StateMachine()
          running = engine_status.new_state()
          idling = engine_status.new_state()
          
          expect(running).toRepondTo('state_machine')
          expect(engine_status.states()).toInclude(running, idling)
          
        it 'should generate states with rpm', ->
          engine_status = new StateMachine()
          running = engine_status.new_state()
          
          expect(running).toBeA(State)
          expect(running).toHave('rpm')

Is it any good?
---

[Yes][y].

[y]: http://news.ycombinator.com/item?id=3067434
          
*Why* is it any good?
---

Let's take it point by point:

1. Underscore is a utility-belt library for Javascript. If you're using [Backbone.js][b], you are already using [Underscore][_]. If you aren't using either, you are excused from class, this library does not apply to your project.
2. Jasmine is a [Test-Driven Development][tdd] testing framework for Javascript. You can run tests in a pretty browser window, you can run tests on the command line with Node.js, you can run tests in the console. If you are writing Javascript and/or Coffeescript, you should be using Jasmine.
3. If you are using Underscore or Backbone and you are using Jasmine, your tests will be cleaner and more readable with these Underscore matchers for the same reason that your code is cleaner and more readable with Underscore.

[tdd]: http://en.wikipedia.org/wiki/Test_Driven_Development
[b]: http://documentcloud.github.com/backbone/

Which matchers are included?
---

Read the code in [Coffeescript][5] or [Javascript][6].

Or, here's the "tl;dr:"

    # collections:
    
    expect([...]).toBeEmpty()         or expect(new Backbone.Collection(...)).toBeEmpty()
    expect([...]).toInclude(foo, bar) or expect(new Backbone.Collection(...)).toInclude(foo, bar)
    expect([...]).toIncludeAny(blitz) or expect(new Backbone.Collection(...)).toIncludeAny(blitz)
    expect([...]).toBeCompact()       or expect(new Backbone.Collection(...)).toBeCompact()
    expect([...]).toBeUnique()        or expect(new Backbone.Collection(...)).toBeUnique()

    # object methods
    
    expect(foo).toRespondTo('push', 'pop')
    expect(foo).toRespondToAny('push', 'isEmpty')
    
    # object properties
    
    expect(foo).toHave('length', 'arity')
    expect(foo).toHaveAny('length', 'size')

    # OO and is-a (all synonymous)
    
    expect(new Foo()).toBeAnInstanceOf(Foo)
    expect(new Foo()).toBeA(Foo)
    expect(new Foo()).toBeAn(Foo)

[5]: https://github.com/raganwald/Underscore-Matchers-for-Jasmine/blob/master/lib/UnderscoreMatchersForJasmine.coffee
[6]: https://github.com/raganwald/Underscore-Matchers-for-Jasmine/blob/master/lib/UnderscoreMatchersForJasmine.js

Are there any more?
---

This is what I happen to need right now for my actual code. **As I write more matchers, I'll add them**. So, if you're interested, watch the library. I suppose I could go through and make a matcher for every function in Underscore, but I'd rather let it grow organically. If there's a matcher you need that isn't here, well, **we're all in the same boat**:

* If you're a *passenger*, send me a message describing the matcher you want. If it seems useful, I'll add it.
* If you're a *sailor*, fork this project, add the matcher, and send me a pull request.
* If you're the *captain of your own ship*, and you've already written some matchers like this, run up some signal flags and I'll include links to your project right here.
* And if you're a *pirate*, take this code and/or just the idea and make your own library. I'm cool with that.

I use jasmine-node. Can I install it with npm?
---

Yes:

    npm install UnderscoreMatchersForJasmine

Can I install it in other kinds of projects?
---

If you're using Coffeescript, put `underscore_matchers.coffee` in your project. If you're using plain Javascript, it should therefore follow that you want to put `underscore_matchers.js` in your project. You can also put `underscore_matchers_spec.coffee` or `underscore_matchers_spec.js` in your project if you want to see these matchers test themselves. It's also handy documentation for how the matchers behave!

Is it free?
---

[Yes][4].

[4]: https://github.com/raganwald/Underscore-Matchers-for-Jasmine/blob/master/license.txt

Other Random Observations
---

**Who's Using This?**

I am.

**Is there a gem?**

No. This is a Coffeescript and Javascript include file, not a ruby library. Coffeescript and Javascript files work everywhere, and you can read the source any time you want.

**Any gotchas?**

Some matchers, such as `toInclude(...)` and `toRespondTo(...)` can take multiple arguments. When they do, they have "all" semantics. For example:
    
    expect([1,2,3,4,5]).toRespondTo('push', 'pop')
      // => succeeds because arrays respond to .push and .pop

    expect([1,2,3,4,5]).toInclude(2,3,4,5,6)
       // => fails because 6 is not included.
      
Now what if you want to test the opposite?

    expect([1,2,3,4,5]).not.toInclude(2,3,4,5,6)
      // succeeds because it doesn't include 2, 3, 4, 5, AND 6.
      
If that's what you want, fine. But if what you really want is to test whether it doesn't include ANY of the arguments, you need a slightly different matcher:
    
    expect([1,2,3,4,5]).toRespondToAny('push', 'select_sql', 'diagonalize')
      // => succeeds because arrays respond to at least one of the three methods given

    expect([1,2,3,4,5]).toIncludeAny(2,3,4,5,6)
      //  => succeeds because it includes at least one of the arguments

The opposite of an "any" matcher is a "none" matcher:

    expect([1,2,3,4,5]).not.toIncludeAny(3, 6, 9)
      //  => fails because [1,2,3,4,5] includes a 3

    expect([1,2,3,4,5]).not.toIncludeAny(6, 9, 12)
      //  => succeeds because [1,2,3,4,5] does not include ANY of the aarguments


**Is this just for underscore stuff?**

No. I also sneak in some Backbone stuff here and there, but the code works just fine even if you don't use Backbone.js. For example:

    $ ->
      describe 'States', ->
        it 'should permit cards to be added and removed', ->
          state = new State()
          card = new Card()
          expect(state.cards()).toBeEmpty()
          state.cards().add(card)
          expect(state.cards()).not.toBeEmpty()
          state.cards().remove(card)
          expect(state.cards()).toBeEmpty()
          
`toBeEmpty` is more than just a wrapper for `_.isEmpty`:

    expect(
      _([]).isEmpty()
    ).toBeTruthy() // => succeeds
    
    expect(
      _(new Backbone.Collection()).isEmpty()
    ).toBeTruthy() // => fails, wtf!?
    
    expect([]).toBeEmpty()
      // => succeeds
      
    expect(new Backbone.Collection()).toBeEmpty()
      // => succeeds
      
The same goes for collection tests like `.toInclude`. You can pass it a backbone collection or an array as you see fit. If you don't want that behaviour, Jasmine includes a `contains()` matcher that expects an array.