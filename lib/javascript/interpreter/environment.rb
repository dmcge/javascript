module Javascript
  class Interpreter::Environment
    attr_reader :parent, :bindings

    def initialize(parent: nil)
      @parent   = parent
      @bindings = {}
    end

    def [](name)
      bindings[name] or parent&.[](name)
    end

    def []=(name, value)
      bindings[name] = Binding.new(value)
    end

    def define(names)
      Array(names).map do |name|
        bindings[name] = Binding.allocate
      end
    end
  end
end
