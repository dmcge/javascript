require "test_helper"

class BinaryLessThanOrEqualTest < Javascript::Test
  def test_comparing_numbers
    assert evaluate("1 <= 1").true?
    assert evaluate("2 <= 3").true?
    refute evaluate("1_000 <= 999").true?
  end

  def test_comparing_strings
    assert evaluate(%("abc" <= 'abc')).true?
    assert evaluate(%("a" <= 'b')).true?
    refute evaluate(%("zyx" <= 'xyz')).true?
  end

  def test_comparing_numeric_strings_and_numbers
    assert evaluate(%("0" <= 0)).true?
    assert evaluate(%("1" <= 2)).true?
    refute evaluate(%(2 <= "1")).true?
  end

  def test_comparing_non_numeric_strings_and_numbers
    refute evaluate(%("x" <= 3)).true?
    refute evaluate(%(3 <= "x")).true?
  end
end
