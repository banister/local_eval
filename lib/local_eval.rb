direc = File.dirname(__FILE__)

require "#{direc}/local_eval/version"
require 'remix'
require 'object2module'

module LocalEval
  module ObjectExtensions
    def local_eval(*objs, &block)
      objs = Array(self) if objs.empty?
      context = eval('self', block.binding)

      # if the receiver is the same as the block context then don't
      # mix in anything, as functionality is already present.
      if objs.include?(context)
        objs.delete(context)
      end
        
      return yield if objs.empty?

      # add functionality to anonymous module to ease mixing and unmixing
      functionality = Module.new.gen_include *objs.map { |o| o.is_a?(Module) ? o.singleton_class : o }
      
      context.temp_extend functionality,
                          :before => proc { context.instance_variable_set(__context_self_name__, self) },
                          :after => proc { context.send(:remove_instance_variable, __context_self_name__) },
                          &block
    end
    alias_method :local_eval_with, :local_eval

    def capture(&block)
      if instance_variable_defined?(__context_self_name__)
        instance_variable_get(__context_self_name__).instance_eval &block
      else
        yield
      end
    end

    def __context_self_name__
      "@__self__#{Thread.current.object_id}"
    end
    
  end
end

class Object
  include LocalEval::ObjectExtensions
end
