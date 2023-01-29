require "test_helper"

class BinaryBitwiseXorTest < Javascript::Test
  def test_xoring_numbers
    assert_equal 0, evaluate("1 ^ 1")
    assert_equal 1, evaluate("0 ^ 1")
    assert_equal 1, evaluate("1 ^ 0")
    assert_equal 1, evaluate("0b111 ^ 0b110")
    assert_equal 0b1010, evaluate("0b1100 ^ 0b110")
  end

  def test_xoring_floats
    assert_equal 0, evaluate("3.1 ^ 3.5")
    assert_equal 3, evaluate("3.2 ^ 0.5")
  end

  def test_xing_negative_numbers
    assert_equal -1, evaluate("-0b101010101 ^ 0b101010100")
    assert_equal -0b111, evaluate("0b101010101 ^ -0b101010100")
    assert_equal 0b111, evaluate("-0b101010101 ^ -0b101010100")
  end

  def test_xoring_numeric_strings
    assert_equal 0b11, evaluate(%("5" ^ 0b110))
    assert_equal 0b110000, evaluate(%(10 ^ "0b111010"))
    assert_equal 0b1, evaluate(%("0b111" ^ "0b110"))
  end

  def test_xoring_nonnumeric_strings
    assert_equal 1, evaluate(%(1 ^ "a"))
    assert_equal 2, evaluate(%("b" ^ 2))
    assert_equal 0, evaluate(%("c" ^ "d"))
  end

  def test_xoring_numbers_bigger_than_32_bits
    assert_equal 1, evaluate("(2 ** 64) ^ 1")
    assert_equal 1, evaluate("1 ^ (2 ** 64)")
    assert_equal 0, evaluate("(2 ** 65) ^ (2 ** 64)")
  end

  def test_xoring_infinity
    assert_equal 1, evaluate(%("Infinity" ^ 1))
    assert_equal 1, evaluate(%(1 ^ "Infinity"))
    assert_equal 0, evaluate(%("Infinity" ^ "Infinity"))
  end
end
