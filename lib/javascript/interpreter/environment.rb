module Javascript
  class Interpreter
    class Environment
      attr_reader :parent, :bindings

      def initialize(parent: nil)
        @parent   = parent
        @bindings = {}
      end

      def [](name)
        bindings[name] or parent&.[](name) or raise("Couldn’t find #{name}")
      end

      def []=(name, value)
        bindings[name] = make_reference(value)
      end

      def define(variables)
        Array(variables).each do |variable|
          self[variable] = nil
        end
      end

      private
        def make_reference(value)
          if value.is_a?(Reference)
            value
          else
            Reference.new(value)
          end
        end
    end
  end
end
