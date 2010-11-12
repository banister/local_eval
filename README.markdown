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
      def hello
        :hello
      end
    end

    o = C.new
    o.local_eval { hello } #=> :hello
    
example: capture
--------------------

`gen_extend` lets us mix objects into objects:

    o = Object.new
    class << o
      def bye
        :bye
      end
    end

    n = Object.new
    n.gen_extend o
    n.bye #=> :bye
    
How it works
--------------

Object2module simply removes the check for `T_MODULE` from `rb_include_module()`

Companion Libraries
--------------------

Remix is one of a series of experimental libraries that mess with
the internals of Ruby to bring new and interesting functionality to
the language, see also:

* [Remix](http://github.com/banister/remix) - Makes ancestor chains read/write
* [Include Complete](http://github.com/banister/include_complete) - Brings in
  module singleton classes during an include. No more ugly ClassMethods and included() hook hacks.
* [Prepend](http://github.com/banister/prepend) - Prepends modules in front of a class; so method lookup starts with the module
* [GenEval](http://github.com/banister/gen_eval) - A strange new breed of instance_eval

Contact
-------

Problems or questions contact me at [github](http://github.com/banister)



