module Javascript
  class Interpreter
    class Environment
      class Binding
        attr_accessor :read_only

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
          if initialized? && !read_only
            @value = value
          else
            raise
          end
        end
      end
    end
  end
end
