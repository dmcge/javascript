require "test_helper"

class CommaTest < Javascript::Test
  def test_comma
    assert_equal 2, evaluate("1, 2")
    assert_equal 1, evaluate("true, false, null, 1")
  end

  def test_operands_must_evaluate_to_a_value
    assert_raises { evaluate("a, 1") }
    assert_raises { evaluate("1, a") }
  end
end
