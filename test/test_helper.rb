require "minitest/autorun"
require "bundler/setup"
require "javascript"

module Javascript
  class Test < Minitest::Test
    private

    def evaluate(script)
      Interpreter.new(script).execute
    end


    def assert_invalid(script)
      assert_raises(SyntaxError) { evaluate(script) }
    end

    def assert_valid(script)
      assert evaluate(script)
    end
  end
end
