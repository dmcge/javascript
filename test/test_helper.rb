require "minitest/autorun"
require "evaluator"

module Javascript
  class Test < Minitest::Test
    private

    def evaluate(script)
      Evaluator.new(script).evaluate
    end
  end
end
