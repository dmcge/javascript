require "minitest/autorun"
require "evaluator"

class NumberTest < Minitest::Test
  def test_integer_literals
    assert_equal 69, evaluate("69")
    assert_equal 420, evaluate("420")
  end

  def test_decimal_literals
    assert_equal 3.1415, evaluate("3.1415")
    assert_equal 0.2748927492, evaluate("0.2748927492")
    assert_raises { evaluate("3.1.415") }
  end

  def test_signing
    assert_equal 78247, evaluate("+78247")
    assert_equal 782.2424, evaluate("+782.2424")
    assert_equal -2424, evaluate("-2424")
    assert_equal -2.8092, evaluate("-2.8092")

    assert_equal 0, evaluate("-1+1")
    assert_equal 0, evaluate("+1-1")
    assert_equal 0, evaluate("1 + -1")
  end

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
    assert_equal Float::INFINITY, evaluate("24 / 0")
  end

  def test_bodmas
    assert_equal 14, evaluate("2 + 3 * 4")
    assert_equal 84, evaluate("7 * 4 * 6 / 2")
    assert_equal 31, evaluate("7 * 4 + 6 / 2")
    # assert_equal 20, evaluate("(2 + 3) * 4")
  end

  private
    def evaluate(script)
      Evaluator.new(script).evaluate
    end
end
