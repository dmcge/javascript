require "minitest/autorun"
require "bundler/setup"
require "javascript"

module Javascript
  class Test < Minitest::Test
    private

    def evaluate(script)
      Interpreter.new(script).evaluate
    end
  end
end
