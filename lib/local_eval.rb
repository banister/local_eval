direc = File.dirname(__FILE__)

require "#{direc}/local_eval/version"
require 'remix'
require 'object2module'

module LocalEval
  
  module ObjectExtensions

    # A more general version of `local_eval`.
    # `local_eval_with` allows you to inject arbitrary functionality
    # from any number of objects into the block. 
    # @param [Array] objs The objects to provide functionality to the block
    # @return The value of the block
    # @example
    #   class A; def self.a; puts "a"; end; end
    #   class B; def self.b; puts "b"; end; end
    #   class C; def self.c; puts "c"; end; end
    #   local_eval_with(A, B, C) { a; b; c }
    #   #=> "a"
    #   #=> "b"
    #   #=> "c"
    def local_eval_with(*objs, &block)
      raise "need a block" if !block_given?
      
      objs = Array(self) if objs.empty?
      context = eval('self', block.binding)

      # if the receiver is the same as the block context then don't
      # mix in anything, as functionality is already present.
      if objs.include?(context)
        objs.delete(context)
        return yield if objs.empty?
      end

      # add functionality to anonymous module to ease mixing and unmixing
      functionality = Module.new.gen_include *objs.map { |o| o.is_a?(Module) ? o.singleton_class : o }
      
      # mix the anonymous module into the block context
      context.temp_extend functionality, &block
    end
    private :local_eval_with

    # Performs a `local_eval` on the block with respect to the
    # receiver.
    # `local_eval` has some advantages over `instance_eval` in that it
    # does not change `self`. Instead, the functionality in the block
    # context is supplemented by the functionality in the
    # receiver. 
    # @return The return value of the block
    # @yield The block to `local_eval`
    # @example local ivars can be looked up
    #   class C
    #     def hello(name)
    #       "hello #{name}!"
    #     end
    #   end
    #   
    #   o = C.new
    #   
    #   @name = "John"
    #   o.local_eval { hello(@name) } #=> "hello John!"
    def local_eval(&block)
      local_eval_with(&block)
    end

    # Since `local_eval` does not alter the `self` inside a block,
    # all methods with an implied receiver will be invoked with respect to
    # this self. This means that all mutator methods defined on the receiver
    # will modify state on the block's self rather than on the receiver's
    # self. This is unlikely to be the desired behaviour; and so
    # using the `capture` method we can redirect the method lookup to
    # the actual receiver. All code captured by the `capture` block
    # will be `instance_eval`'d against the actual receiver of the
    # method.
    # @return The return value of the block.
    # @yield The block to be evaluated in the receiver's context.
    # @example
    #   class C
    #     def self.hello() @hello end
    #     def self.capture_test
    #     
    #       # this code will be run against C
    #       capture { @hello = :captured }
    #
    #       # this code will be run against the block context
    #       @goodbye = :goobye
    #     end
    #   end
    #
    #   C.local_eval { capture_test }
    #   C.hello #=> :captured
    #   @goodbye #=> :goodbye
    def capture(&block)
      
      # 1. Get name of enclosing method (method that invoked
      # `capture ` block)
      # 2. Find owner of enclosing method (owner is guaranteed to be
      # a singleton class)
      # 4. Find associated object (attached object) of the singleton class
      # 5. This object will be the receiver of the method call, so
      # instance_eval on it.
      method_name = eval('__method__', block.binding)
      method_owner = method(method_name).owner
      attached_object = method_owner.__attached__
      attached_object.instance_eval &block
    end
    alias_method :__capture__, :capture
    
  end
end

class Object
  include LocalEval::ObjectExtensions
end
