require "test_helper"

class NumberTest < Javascript::Test
  def test_addition
    assert_equal 4, evaluate("1 + 1 + 2")
    assert_equal 4294967297, evaluate("2274827419 + 2020139878")
    assert_equal 4.5, evaluate("1.1 + 3.4")
  end

  def test_subtraction
    assert_equal 0, evaluate("2 - 1 - 1")
    assert_equal 2274827419, evaluate("4294967297 - 2020139878")
    assert_equal 0.333, evaluate("0.666 - 0.333")
  end

  def test_multiplication
    assert_equal 0, evaluate("24 * 0 * 12")
    assert_equal 1, evaluate("1 * 1")
    assert_equal 4, evaluate("2 * 2")
    assert_equal 8710193678316, evaluate("4294967297 * 2028")
  end

  def test_division
    assert_equal 1, evaluate("2 / 2 / 1")
    assert_equal 5, evaluate("10 / 2")
    assert_equal 0.75, evaluate("3 / 4")
    assert_equal 2028, evaluate("8710193678316 / 4294967297")
    assert_equal BigDecimal("0.333333333333333333333333333333333333"), evaluate("1/3")
    assert_equal BigDecimal("0.1666666666666666666666666666666666665"), evaluate("1/3/2")
  end

  def test_dividing_by_zero
    assert_equal Float::INFINITY, evaluate("24 / 0")
    assert_equal -Float::INFINITY, evaluate("24 / -0")
    assert_equal -Float::INFINITY, evaluate("-24 / 0")
  end

  def test_exponentiation
    assert_equal 100, evaluate("10 ** 2")
    assert_equal 10, evaluate("100 ** 0.5")
    assert_equal 0.01, evaluate("100 ** -1")
  end

  def test_bodmas
    assert_equal 50, evaluate("100 ** 1/2")
    assert_equal 14, evaluate("2 + 3 * 4")
    assert_equal 84, evaluate("7 * 4 * 6 / 2")
    assert_equal 31, evaluate("7 * 4 + 6 / 2")
    # assert_equal 20, evaluate("(2 + 3) * 4")
  end

  def test_less_than
    assert evaluate("2 < 4")
    assert evaluate("2 ** 2 < 2 + 1 * 3")
    refute evaluate("1_000 < 999")
    refute evaluate("2 * 2 < 3 + 1")
  end

  def test_less_than_or_equal
    assert evaluate("2 <= 4")
    assert evaluate("2 * 2 <= 3 + 1")
    refute evaluate("1_000 < 999")
  end

  def test_greater_than
    assert evaluate("1_000 > 999")
    assert evaluate("3 + 2 ** 2 > 2 * 2")
    refute evaluate("2 > 4")
    refute evaluate("2 * 2 > 3 + 1")
  end

  def test_greater_than_or_equal
    assert evaluate("1_000 >= 999")
    assert evaluate("2 * 2 >= 3 + 1")
    refute evaluate("2 > 4")
  end

  def test_modulo
    assert_equal 1, evaluate("5 % 2")
    assert_equal 0, evaluate("6 % 3")
    assert_equal 8, evaluate("10 * 2 % 3 * 4")
    assert_equal 7, evaluate("10 * 2 % 3 * 4 - 1")
  end

  def test_shifting_left
    assert_equal 0b100100, evaluate("0b1001 << 2")
    assert_equal -0b11101000, evaluate("-0b11101 << 3")
    assert_equal 0b101010, evaluate("0b10101 << 33")
    assert_equal evaluate("3 << 1"), evaluate("3.9999 << 1")
  end

  def test_shifting_right
    assert_equal 0b11, evaluate("0b1101 >> 2")
    assert_equal -0b101, evaluate("-0b100101 >> 3")
    assert_equal 0b1010, evaluate("0b10101 >> 33")
    assert_equal evaluate("3 >> 1"), evaluate("3.9999 >> 1")
  end

  def test_shifting_right_unsigned
    assert_equal 0b11, evaluate("0b1101 >>> 2")
    assert_equal 0b11111111111111111111111111011, evaluate("-0b100101 >>> 3")
    assert_equal 0b1010, evaluate("0b10101 >>> 33")
    assert_equal evaluate("-3 >>> 1"), evaluate("-3.9999 >>> 1")
  end


  def test_dangling_operators
    assert_raises { evaluate("+") }
    assert_raises { evaluate("3 *") }
    assert_raises { evaluate("/ 2") }
  end
end
