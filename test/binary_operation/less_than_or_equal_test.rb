require "test_helper"

class BinaryLessThanOrEqualTest < Javascript::Test
  def test_comparing_numbers
    assert evaluate("1 <= 1")
    assert evaluate("2 <= 3")
    refute evaluate("1_000 <= 999")
  end

  def test_comparing_strings
    assert evaluate(%("abc" <= 'abc'))
    assert evaluate(%("a" <= 'b'))
    refute evaluate(%("zyx" <= 'xyz'))
  end

  def test_comparing_numeric_strings_and_numbers
    assert evaluate(%("0" <= 0))
    assert evaluate(%("1" <= 2))
    refute evaluate(%(2 <= "1"))
  end

  def test_comparing_non_numeric_strings_and_numbers
    refute evaluate(%("x" <= 3))
    refute evaluate(%(3 <= "x"))
  end
end
