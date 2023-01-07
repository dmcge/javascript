require "test_helper"

class BinaryModuloTest < Javascript::Test
  def test_modulus_of_numbers
    assert_equal 1, evaluate("5 % 2")
    assert_equal 0, evaluate("6 % 3")
  end

  def test_modulus_of_numeric_strings
    assert_equal 1, evaluate(%("16" % "5"))
    assert_equal 2, evaluate(%("26" % 4))
    assert_equal 5, evaluate(%(35 % '6'))
  end

  def test_modulus_of_non_numeric_strings
    assert evaluate(%("a" % 8)).nan?
    assert evaluate(%("b" % "c")).nan?
    assert evaluate(%(9 % "d")).nan?
  end

  def modulus_with_negative_numbers
    assert_equal -12, evaluate("-12 % 32")
    assert_equal 12, evaluate("12 % -32")
  end

  def test_modulus_with_infinity
    assert evaluate(%("Infinity" % 8)).nan?
    assert evaluate(%(-"Infinity" % 8)).nan?
    assert_equal 8, evaluate(%(8 % "Infinity"))
  end
end
