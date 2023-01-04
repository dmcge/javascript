require "minitest/autorun"
require "interpreter"

module Javascript
  class Test < Minitest::Test
    private

    def evaluate(script)
      Interpreter.new(script).evaluate
    end
  end
end
