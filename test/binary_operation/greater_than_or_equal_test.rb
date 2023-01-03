require "test_helper"

class BinaryGreaterThanOrEqualTest < Javascript::Test
  def test_comparing_numbers
    assert evaluate("3 >= 3")
    assert evaluate("1_000 >= 999")
    refute evaluate("2 >= 4")
  end

  def test_comparing_strings
    assert evaluate(%("abc" >= 'abc'))
    assert evaluate(%("z" >= 'x'))
    assert evaluate(%("zyxw" >= 'zyx'))
    refute evaluate(%("abc" >= 'def'))
  end

  def test_comparing_numeric_strings_and_numbers
    assert evaluate(%("0" >= 0))
    assert evaluate(%(2 >= "1"))
    refute evaluate(%(1 >= "2"))
  end

  def test_comparing_non_numeric_strings_and_numbers
    refute evaluate(%("x" >= 3))
    refute evaluate(%(3 >= "x"))
  end
end
