require "test_helper"

class BinaryMultiplicationTest < Javascript::Test
  def test_multiplying_numbers
    assert_equal 1, evaluate("1 * 1")
    assert_equal 4, evaluate("2 * 2")
    assert_equal 0, evaluate("3 * 0")
    assert_equal 8710193678316, evaluate("4294967297 * 2028")
  end

  def test_multiplying_numeric_strings
    assert_equal 15, evaluate(%("3" * "5"))
    assert_equal 24, evaluate(%("4" * 6))
    assert_equal 35, evaluate(%(5 * '7'))
  end

  def test_multiplying_non_numeric_strings
    assert evaluate(%("a" * 8)).nan?
    assert evaluate(%("b" * "c")).nan?
    assert evaluate(%(9 * "d")).nan?
  end

  def test_multiplying_with_negative_numbers
    assert_equal -4, evaluate("2 * -2")
    assert_equal -4, evaluate("-2 * 2")
    assert_equal 4, evaluate("-2 * -2")
  end

  def test_multiplying_with_infinity
    assert_equal Float::INFINITY, evaluate(%(2 * "Infinity"))
    assert_equal Float::INFINITY, evaluate(%("Infinity" * 3))
  end
end
