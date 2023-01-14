require "test_helper"

class FunctionTest < Javascript::Test
  def test_function_calls
    assert_equal 5, evaluate(<<~JS)
      function add(a, b) {
        return a + b
      }

      add(2, 3)
    JS
  end

  def test_anonymous_functions
    assert_equal 20, evaluate(<<~JS)
      var multiply = function(a, b) {
        return a * b
      }

      multiply(4, 5)
    JS
  end
end
