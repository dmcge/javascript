require "test_helper"

class BinarySubtractionTest < Javascript::Test
  def test_subtracting_numbers
    assert_equal 18, evaluate("24 - 6")
    assert_equal 0.333, evaluate("0.666 - 0.333")
  end

  def test_associativity
    assert_equal 0, evaluate("5 - 3 - 2")
  end

  def test_subtracting_numeric_strings
    assert_equal 4, evaluate(%("14" - "10"))
    assert_equal 3, evaluate(%("10" - 7))
    assert_equal 2, evaluate(%(6 - '4'))
  end

  def test_subtracting_non_numeric_strings
    assert evaluate(%("a" - 8)).nan?
    assert evaluate(%("b" - "c")).nan?
    assert evaluate(%(9 - "d")).nan?
  end

  def test_subtracting_with_negative_numbers
    assert_equal -3, evaluate("-1 - 2")
    assert_equal 3, evaluate("1 - -2")
    assert_equal 1, evaluate("-1 - -2")
  end
end
