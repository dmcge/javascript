module Javascript
  class Interpreter
    class Context
      attr_accessor :environment

      def initialize
        self.environment = Environment.new
      end

      def in_environment(environment)
        previous_environment = self.environment
        self.environment = environment
        yield
      ensure
        self.environment = previous_environment
      end

      def in_new_environment(parent: environment, &)
        in_environment(Environment.new(parent: parent), &)
      end
    end
  end
end
