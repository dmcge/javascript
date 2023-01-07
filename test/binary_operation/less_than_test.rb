require "test_helper"

class BinaryLessThanTest < Javascript::Test
  def test_comparing_numbers
    assert evaluate("2 < 4").true?
    refute evaluate("1_000 < 999").true?
  end

  def test_comparing_strings
    assert evaluate(%("a" < 'b')).true?
    assert evaluate(%("abc" < 'abcdef')).true?
    refute evaluate(%("zyx" < 'xyz')).true?
  end

  def test_comparing_numeric_strings_and_numbers
    assert evaluate(%("-Infinity" < 0)).true?
    refute evaluate(%("Infinity" < 0)).true?
  end

  def test_comparing_non_numeric_strings_and_numbers
    refute evaluate(%("x" < 3)).true?
    refute evaluate(%(3 < "x")).true?
  end
end
