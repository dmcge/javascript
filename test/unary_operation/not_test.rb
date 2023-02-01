require "test_helper"

class UnaryNotTest < Javascript::Test
  def test_negating
    assert evaluate("!0").true?
    assert evaluate(%(!"")).true?

    refute evaluate("!1").true?
    refute evaluate(%(!"true")).true?
  end

  def test_negating_arbitrary_expressions
    assert evaluate("!(1 - 1 ** 1)").true?
  end

  def test_coercing_to_boolean
    assert evaluate("!!1").true?
    refute evaluate("!!0").true?
  end

  def test_postfix
    assert_invalid "3!"
  end
end
