module Min
  class MethodNotFound < RuntimeError; end
  
  class Object
    attr_accessor :vtable
    
    def initialize(vtable)
      @vtable = vtable
    end
    
    def min_send(context, message, *args)
      if method = min_method(context, message)
        method.call(context, self, *args)
      else
        raise MethodNotFound, "Method not found #{message} on #{inspect}"
      end
    end
    
    def min_method(context, message)
      # short-circuit to break recursion in send.
      if message == :lookup && is_a?(VTable)
        @vtable.lookup(context, message)
      else
        @vtable.min_send(context, :lookup, message.to_min)
      end
    end
    
    def eval(context)
      self
    end
    
    def self.bootstrap(runtime)
      object = runtime[:Object]
      object.vtable.add_method(:vtable, RubyMethod.new(:vtable))
      object.vtable.add_method(:puts, proc { |context, obj, str| puts str.eval(context).value })
      object.vtable.add_method(:eval, proc { |context, obj, code| runtime.eval(code.eval(context).value, context) })
      object.vtable.add_method(:load, proc { |context, obj, file| runtime.load(file.eval(context).value) })
    end
  end
end