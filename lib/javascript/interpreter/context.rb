module Javascript
  class Interpreter::Context
    attr_accessor :environment

    def initialize
      self.environment = Interpreter::Environment.new
    end

    def in_environment(environment)
      previous_environment = self.environment
      self.environment = environment
      yield
    ensure
      self.environment = previous_environment
    end

    def in_new_environment(parent: environment, &)
      in_environment(Interpreter::Environment.new(parent: parent), &)
    end
  end
end
