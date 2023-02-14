module Javascript
  class Interpreter
    class Context
      attr_accessor :environment

      def initialize
        self.environment = Environment.new
      end

      def enter_new_environment
        self.environment = Environment.new(environment)
        yield
      ensure
        self.environment = environment.parent
      end
    end
  end
end
