require "test_helper"

class BinaryDivisionTest < Javascript::Test
  def test_dividing_numbers
    assert_equal 5, evaluate("10 / 2")
    assert_equal 0.75, evaluate("3 / 4")
    assert_equal 0.3333333333333333, evaluate("1/3")
  end

  def test_dividing_numeric_strings
    assert_equal 3, evaluate(%("15" / "5"))
    assert_equal 4, evaluate(%("24" / 6))
    assert_equal 5, evaluate(%(35 / '7'))
  end

  def test_dividing_non_numeric_strings
    assert_equal Float::NAN, evaluate(%("a" / 8))
    assert_equal Float::NAN, evaluate(%("b" / "c"))
    assert_equal Float::NAN, evaluate(%(9 / "d"))
  end

  def test_dividing_with_negative_numbers
    assert_equal -0.3333333333333333, evaluate("-1 / 3")
    assert_equal -0.3333333333333333, evaluate("1 / -3")
    assert_equal 0.3333333333333333, evaluate("-1 / -3")
  end

  def test_dividing_by_zero
    assert_equal Float::INFINITY, evaluate("24 / 0")
    assert_equal -Float::INFINITY, evaluate("24 / -0")
    assert_equal -Float::INFINITY, evaluate("-24 / 0")
  end

  def test_dividing_zero_by_zero
    assert_equal Float::NAN, evaluate("0 / 0")
    assert_equal Float::NAN, evaluate("-0 / 0")
    assert_equal Float::NAN, evaluate("0 / -0")
  end

  def test_dividing_with_infinity
    assert_equal Float::INFINITY, evaluate(%("Infinity" / 24))
    assert_equal 0, evaluate(%(24 / "Infinity"))
  end
end
