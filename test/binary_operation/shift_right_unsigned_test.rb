require "test_helper"

class BinaryShiftRightUnsignedTest < Javascript::Test
  def test_shifting_positive_numbers
    assert_equal 0b11, evaluate("0b1101 >>> 2")
    assert_equal 0b1010, evaluate("0b10101 >>> 33")
  end

  def test_shifting_negative_numbers
    assert_equal 0b111111111111111111111111111100, evaluate("-0b1101 >>> 2")
    assert_equal 0b11111111111111111111111111011, evaluate("-0b100101 >>> 3")
  end

  def test_shifting_numeric_strings
    assert_equal 0b10, evaluate(%("0b1001" >>> "2"))
    assert_equal 0, evaluate(%("0b10101" >>> -33))
    assert_equal 0b11111111111111111111111111100, evaluate(%(-0b11101 >>> "3"))
  end

  def test_shifting_non_numeric_strings
    assert_equal 0, evaluate(%("a" >>> 8))
    assert_equal 0, evaluate(%("b" >>> "c"))
    assert_equal 9, evaluate(%(9 >>> "d"))
  end

  def test_shifting_infinity
    assert_equal 0, evaluate(%("Infinity" >>> 12))
    assert_equal 12, evaluate(%(12 >>> "Infinity"))
  end

  def test_shifting_a_number_bigger_than_32_bits
    assert_equal 0, evaluate("-(2 ** 64) >>> 12")
    assert_equal 1546648576, evaluate("(3 ** 39) >>> 1")
    assert_equal 600835072, evaluate("-(3 ** 39) >>> 1")
  end

  def test_shifting_by_a_negative_number
    assert_equal 0, evaluate(%(0b1001 >>> -2))
    assert_equal 0, evaluate(%(0b10101001 >>> -2))
    assert_equal 0b11, evaluate(%(-0b10101001 >>> -2))
  end
end
