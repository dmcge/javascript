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
end
