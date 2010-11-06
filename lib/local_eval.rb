direc = File.dirname(__FILE__)

require "#{direc}/local_eval/version"
require 'remix'
require 'object2module'

module LocalEval
  module ObjectExtensions
    LocalEvalMutex = Mutex.new
    def local_eval(*objs, &block)
      objs = Array(self) if objs.empty?
      functionality = Module.new.gen_include(*objs)
      context = eval('self', block.binding)
      val = nil
      LocalEvalMutex.synchronize do
        context.instance_eval { @__local_eval_mutex__ ||= Mutex.new }
      end.synchronize do
        begin
          context.gen_extend(functionality)
          context.instance_variable_set(__context_self_name__, self)
          val = yield
        ensure
          context.unextend(functionality, true)
          context.send(:remove_instance_variable, __context_self_name__)
        end
      end
      val
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
