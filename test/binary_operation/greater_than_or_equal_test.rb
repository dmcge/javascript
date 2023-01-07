require "test_helper"

class BinaryGreaterThanOrEqualTest < Javascript::Test
  def test_comparing_numbers
    assert evaluate("3 >= 3").true?
    assert evaluate("1_000 >= 999").true?
    refute evaluate("2 >= 4").true?
  end

  def test_comparing_strings
    assert evaluate(%("abc" >= 'abc')).true?
    assert evaluate(%("z" >= 'x')).true?
    assert evaluate(%("zyxw" >= 'zyx')).true?
    refute evaluate(%("abc" >= 'def')).true?
  end

  def test_comparing_numeric_strings_and_numbers
    assert evaluate(%("0" >= 0)).true?
    assert evaluate(%(2 >= "1")).true?
    refute evaluate(%(1 >= "2")).true?
  end

  def test_comparing_non_numeric_strings_and_numbers
    refute evaluate(%("x" >= 3)).true?
    refute evaluate(%(3 >= "x")).true?
  end
end
