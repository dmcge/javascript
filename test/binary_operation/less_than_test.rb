require "test_helper"

class BinaryLessThanTest < Javascript::Test
  def test_comparing_numbers
    assert evaluate("2 < 4")
    refute evaluate("1_000 < 999")
  end

  def test_comparing_strings
    assert evaluate(%("a" < 'b'))
    assert evaluate(%("abc" < 'abcdef'))
    refute evaluate(%("zyx" < 'xyz'))
  end

  def test_comparing_numeric_strings_and_numbers
    assert evaluate(%("-Infinity" < 0))
    refute evaluate(%("Infinity" < 0))
  end

  def test_comparing_non_numeric_strings_and_numbers
    refute evaluate(%("x" < 3))
    refute evaluate(%(3 < "x"))
  end
end
