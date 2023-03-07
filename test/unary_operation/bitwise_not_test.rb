require "test_helper"

class UnaryBitwiseNotTest < Javascript::Test
  def test_negating_integers
    assert_equal -1, evaluate("~0")
    assert_equal -101, evaluate("~100")
    assert_equal 7, evaluate("~-8")
  end

  def test_negating_floats
    assert_equal -2, evaluate("~1.5")
    assert_equal -8925, evaluate("~8924.2482942894223")
    assert_equal -1, evaluate("~-.395839482")
  end

  def test_negating_numeric_strings
    assert_equal -6, evaluate(%(~"5"))
    assert_equal 14, evaluate(%(~"-15"))
    assert_equal 4, evaluate(%(~"-5.4"))
  end

  def test_negating_non_numeric_strings
    assert_equal -1, evaluate(%(~"not a number"))
    assert_equal -1, evaluate(%(~"baa baa black sheep, have you any wool?"))
  end

  def test_negating_infinity
    assert_equal -1, evaluate(%(~"Infinity"))
    assert_equal -1, evaluate(%(~-"Infinity"))
  end

  def test_negating_a_property
    assert_equal -4, evaluate(<<~JS)
      var object = { a: 3 }
      ~object.a
    JS
  end

  def test_postfix
    assert_malformed "3~"
  end
end
