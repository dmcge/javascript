require "test_helper"

class BinaryEqualityTest < Javascript::Test
  def test_operands_of_same_type
    assert evaluate("0 == 0").true?
    refute evaluate("1 == 2").true?
  end

  def test_strings_and_numbers
    assert evaluate(%("1" == 1)).true?
    assert evaluate(%(2 == "2")).true?
    refute evaluate(%("3" == 4)).true?
    refute evaluate(%(5 == "6")).true?
  end

  def test_booleans_and_numbers
    assert evaluate("3 < 5 == 1").true?
    assert evaluate(%(5 < "3" == 0)).true?
    refute evaluate("4 > 1 == 0").true?
  end

  def test_zero
    assert evaluate("0 == 0").true?
    assert evaluate("-0 == -0").true?
    assert evaluate("0 == -0").true?
    assert evaluate("-0 == 0").true?
  end
end
