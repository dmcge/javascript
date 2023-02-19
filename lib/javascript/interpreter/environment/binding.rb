module Javascript
  class Interpreter
    class Environment
      class Binding
        public def initialize(value = nil)
          if initialized?
            raise
          else
            @value = value
            @initialized = true
          end
        end

        def initialized?
          @initialized
        end

        def value
          if initialized?
            @value
          else
            raise
          end
        end

        def value=(value)
          if initialized?
            @value = value
          else
            raise
          end
        end
      end
    end
  end
end
