direc = File.dirname(__FILE__)

require "#{direc}/local_eval/version"
require 'remix'
require 'object2module'

module LocalEval

  # Thread-local name for the hidden self used by `capture`
  # @return [String] The name of the hidden self used by `capture`
  def self.context_self_name
    "@__self__#{Thread.current.object_id}"
  end

  module ClassExtensions
    
    # Find the instance associated with the singleton class
    # @return [Object] Instance associated with the singleton class
    def __attached__
      ObjectSpace.each_object(self).first
    end
  end
  
  module ObjectExtensions

    def local_eval(*objs, &block)
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
    alias_method :local_eval_with, :local_eval

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
  end
end

class Class
  include LocalEval::ClassExtensions
end

class Object
  include LocalEval::ObjectExtensions
end
