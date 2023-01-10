require "minitest/autorun"
require "bundler/setup"
require "javascript"

module Javascript
  class Test < Minitest::Test
    private

    def evaluate(script)
      Interpreter.new(script).evaluate
    end


    def assert_invalid(script)
      assert_raises { evaluate(script) }
    end

    def assert_valid(script)
      assert evaluate(script)
    end
  end
end
