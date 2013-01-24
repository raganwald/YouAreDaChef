# A Quick Guide to Using YouAreDaChef

### What YouAreDaChef Does

[YouAreDaChef][yadc] is a utility for meta-programming Object-Oriented JavaScript. YouAreDaChef supports modifying JavaScript that is written in either a prototype style or a class-oriented style. JavaScript supports extending and redefining methods out of the box. YouAreDaChef takes this further by also supporting [Aspect-Oriented Programming][aop], specifically "decorating" methods with before, after, around, and guard advice.

[yadc]: http://github.com/raganwald/YouAreDaChef
[aop]: https://en.wikipedia.org/wiki/Aspect-oriented_programming

This is almost exactly like [controller filters][filters] and [ActiveRecord callbacks][callbacks] in Ruby on Rails, but for your JavaScript and [Backbone][bb] objects!

[callbacks]: http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html
[filters]: http://guides.rubyonrails.org/action_controller_overview.html#filters
[bb]: http://documentcloud.github.com/backbone/

Aspect-Oriented Programming is a *code organization* practice. Its purpose is to separate concerns by responsibility, even when the implementation of that responsibility spans multiple classes or has finer granularity than a method. AOP seeks to avoid *tangling* multiple responsibilities in a single class or method body as well as to avoid *scattering* a single responsibility across several classes.

YouAreDaChef operates on classes constructed in CoffeeScript with the `class` keyword like this:

```coffeescript
class Muppet
	name: -> @_name
		
class Animal extends Muppet
	constructor: (@_name) ->
	instrument: -> 'drums'
```

YouAreDaChef also operates on functions with prototype chains hand-rolled in standard JavaScript like this:

```javascript
var Animal, Muppet;

Muppet = function() {};

Muppet.prototype.name = function() {
  return this._name;
};

Animal = function(_name) {
  this._name = _name;
};

Animal.prototype = new Muppet();

Animal.prototype.instrument = function() {
  return 'drums';
};
```

In this document, the words "class" and "method" will be used regardless of how you choose to implement inheritance, and the examples will alternate between CoffeeScript and JavaScript.

### Basic Syntax

Using YouAreDaChef resembles using jQuery. You start with `YouAreDaChef` and then specify what you wish to "advise." In [Café au Life][cafe], the class `Square` has a method called `set_memo` and another called `initialize`, something like this:

[cafe]: http://recursiveuniver.se

```coffeescript
class Square
	initialize: (args...) ->
		# ...
	set_memo: (index, square) ->
		@memoized[index] = square
```

In the [garbage collection][gc] module, YouAreDaChef decorates these methods with before and after advice:

[gc]: http://recursiveuniver.se/docs/gc.html

```coffeescript
    YouAreDaChef
    
      .clazz(Square)
      
        .method('initialize')
          .after ->
            @references = 0
            
        .method('set_memo')
          .before (index) ->
            if (existing = @get_memo(index))
              existing.decrementReference()
          .after (index, square) ->
            square.incrementReference()
```
        
As a result, when a Square's `set_memo` method is called, its "before" advice is executed, then its body or "default" advice is executed, then its "after" advice is executed. If you define more than one before or after advice, they will all be executed in order. Before and after advice is passed the same parameters as the 'default' behaviour but is executed for its side-effects only. There is no way to alter the parameters passed to the default behaviour or to modify its return value.

**Note**: If you are using inheritance, YouAreDaChef arranges things such that all of the before advice is executed, including the inherited advice, but only the most specific method body or "default" is evaluated. In many cases, you can avoid trying to use a `super` method in a subclass by defining method advice in the subclass instead. This makes your intent easier to understand.

### Some Shortcuts

When you only want to provide one piece of advice to one method, you can use 'compact' syntax for specifying the method name as a parameter of the advice:

```javascript
YouAreDaChef
  .clazz(Square)
    .after('initialize', function() {
      this.references = 0;
    });
```

You can also save yourself a line of code by treating `YouAreDaChef` as a function (just like `$(...)` in jQuery) and specifying one or more classes as parameters:

```coffeescript
YouAreDaChef(Square)
  .after 'initialize', ->
    @references = 0
```

You can specify more than one class or more than one method. If you are a stickler for English-y method names, you can call either `.clazz` or `.clazzes` and `.method` or `.methods`, like this:

```javascript
var debug_id = 0;

YouAreDaChef
  .clazzes(Square, Cell)
    .after('initialize', function() {
      debug_id = debug_id + 1;
      this.debug_id = debug_id;
    });
```

And when you want to hand out a lot of the same kind of advice, pass in a hash of methods and advices:

```coffeescript
    YouAreDaChef
    
      .clazz(Square)
      
        .before
          set_memo: (index) ->
            if (existing = @get_memo(index))
              existing.decrementReference()
      
        .after
          initialize: ->
            @references = 0
          set_memo: (index, square) ->
            square.incrementReference()
```

This is equivalent to the example for basic syntax, just organized differently. The purpose of YouAreDaChef is to give you ways to organize your code by responsibility. Thus, it provides multiple ways to declare your advice.

Finally, you can chain as much or as little of your advice together as you want. Just as you can chain advice for different methods or different kinds of advice, you can chain different classes:

```javascript
var debug_id = 0;

YouAreDaChef
  .clazz(Cell)
    .after('initialize', function() {
      debug_id = debug_id + 1;
      this.debug_id = "C" + debug_id;
    });
  .clazz(Square)
    .after('initialize', function() {
      debug_id = debug_id + 1;
      this.debug_id = "S" + debug_id;
    });
```

### Regular Expressions

Instead of using a  method name (or list of method names), you can supply a regular expression to specify the method(s) to be advised. The match data will be passed as the first parameter, so it is possible to use match groups in your advice:

```javascript
EnterpriseyLegume = (function() {

  function EnterpriseyLegume() {}

  EnterpriseyLegume.prototype.setId = function(id) {
    this.id = id;
  };

  EnterpriseyLegume.prototype.setName = function(name) {
    this.name = name;
  };

  EnterpriseyLegume.prototype.setDepartment = function(department) {
    this.department = department;
  };

  EnterpriseyLegume.prototype.setCostCentre = function(costCentre) {
    this.costCentre = costCentre;
  };

  return EnterpriseyLegume;

})();

YouAreDaChef(EnterpriseyLegume)
  .methods(/set(.*)/)
    .after(function(match, value) {
      writeToLog("" + match[1] + " set to: " + value);
    });
```

### Around Advice

Before and after advice are executed for side-effects only. "Around" advice is all-encompassing: It is passed the parameters and the default advice, and it takes care of calling the default advice and deciding what to return. Here is some fictional code that wraps some methods up in a transaction:

```coffeescript
YouAreDaChef(EnterpriseyLegume)
  .around /set(.*)/, (default_fn, match, value) ->
    performTransaction ->
      default_fn(value)
```
          
When multiple pieces of around advice are provided, they nest.

### Guard Advice

Ruby on Rails users are familiar with [controller filters][filters]. YouAreDaChef's before, after, and around advices are like controller filters. Likewise, Ruby on Rails provides [callbacks][callbacks] for ActiveRecord models. YouAreDaChef works just like the callback queues, every class inherits the before, after, and around advice of its superclasses (or prototypes).

[callbacks]: http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html
[filters]: http://guides.rubyonrails.org/action_controller_overview.html#filters

Well, YouAreDaChef works *almost* like Ruby on Rails. The one difference is that YouAreDaChef doesn't care what before advice returns. `false`, `null`, `undefined`, it doesn't matter and it doesn't halt the function call. In Rails, if a before filter returns something falsey, the request cycle is halted.

The behaviour in YouAreDaChef is consistent: before advice is stuff you want to do before the method call, after advice is stuff you want to do after the method call. Always. If you forget to pay attention to what your before advice returns, it won't break your method. But what if you actually want a filter? In that case, you use *guard advice*:

```javascript
YouAreDaChef(EnterpriseyLegume)
  .when('setId', function(value) {
    return !isNaN(value);
  });
```
        
`setId` will be aborted if the value passed is not an integer. This pattern of testing for an error and returning the negation of the test value is common, so YouAreDaChef provides a shortcut:

```coffeescript
YouAreDaChef(EnterpriseyLegume)
  .unless 'setId', (value) -> isNaN(value) # Equivalent to isNaN
```

This has the exact same semantics as the `.when` advice, `.setId` will be evaluated unless the value is not a number.

### Installation

    npm install YouAreDaChef

Or:	

    git clone git://github.com/raganwald/YouAreDaChef.git

Or:

    curl -o YouAreDaChef.zip https://nodeload.github.com/raganwald/YouAreDaChef/zipball/master

### Where can I read more?

[YouAreDaChef README][yadc]  
[Separating Concerns in Coffeescript using Aspect-Oriented Programming][blog]  
[Implementing Garbage Collection in CS/JS with Aspect-Oriented Programming][gc]

[js]: https://github.com/raganwald/YouAreDaChef/blob/master/lib/YouAreDaChef.js
[gc]: https://github.com/raganwald/homoiconic/blob/master/2012/03/garbage_collection_in_coffeescript.md#readme
[blog]: https://github.com/raganwald/homoiconic/blob/master/2011/11/YouAreDaChef.md#readme

### Et cetera

[YouAreDaChef][yadc]  was created by [Reg "raganwald" Braithwaite][raganwald]. It is available under the terms of the [MIT License][lic].

[raganwald]: http://braythwayt.com
[lic]: https://github.com/raganwald/YouAreDaChef/blob/master/license.md
