LocalEval
=============

(C) John Mair (banisterfiend) 2010

_instance\_eval without changing self_

Using `local_eval` you get most of the benefits of `instance_eval`
with very few of the drawbacks: local instance variables are
accessible within the block and method lookups are directed to the
correct receiver. Unlike `instance_eval` the `self` of the
block is not changed.

LocalEval provides the `local_eval` and `local_eval_with` methods.

* Install the [gem](https://rubygems.org/gems/local_eval): `gem install local_eval`
* Read the [documentation](http://rdoc.info/github/banister/local_eval/master/file/README.markdown)
* See the [source code](http://github.com/banister/local_eval)

example: local_eval
--------------------------

Using `local_eval` we can add the functionality of the receiver to the
block:


    class C
      def hello(name)
        "hello #{name}!"
      end
    end

    o = C.new

    @name = "John"
    o.local_eval { hello(@name) } #=> "hello John!"
    
example: capture
--------------------

Since `local_eval` does not alter the `self` inside a block,
all methods with an implied receiver will be invoked with respect to
this self. This means that all mutator methods defined on the receiver
will modify state on the block's self rather than on the receiver's
self. This is unlikely to be the desired behaviour; and so
using the `capture` method we can redirect the method lookup to
the actual receiver. All code captured by the `capture` block
will be `instance_eval`'d against the actual receiver of the method.
     
    class C
      class << self
        attr_reader :hello
        def self.capture_test
         
          # this code will be run against C
          capture { @hello = :captured }
    
          # this code will be run against the block context
          @goodbye = :goobye
        end
      end
    end
    
    C.local_eval { capture_test }

    C.hello #=> :captured
    @goodbye #=> :goodbye

How it works
--------------

Makes use of companion libraries: Remix and Object2module

Companion Libraries
--------------------

LocalEval is one of a series of experimental libraries that mess with
the internals of Ruby to bring new and interesting functionality to
the language, see also:

* [Remix](http://github.com/banister/remix) - Makes ancestor chains read/write
* [Object2module](http://github.com/banister/object2module) - Enables you to include/extend Object/Classes.
* [Include Complete](http://github.com/banister/include_complete) - Brings in
  module singleton classes during an include. No more ugly ClassMethods and included() hook hacks.
* [Prepend](http://github.com/banister/prepend) - Prepends modules in front of a class; so method lookup starts with the module
* [GenEval](http://github.com/banister/gen_eval) - A strange new breed of instance_eval

Contact
-------

Problems or questions contact me at [github](http://github.com/banister)



