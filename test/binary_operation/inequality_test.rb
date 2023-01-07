require "test_helper"

class BinaryInequalityTest < Javascript::Test
  def test_operands_of_same_type
    assert evaluate("1 != 2").true?
    refute evaluate("0 != 0").true?
  end

  def test_strings_and_numbers
    assert evaluate(%("1" != 2)).true?
    assert evaluate(%(3 != "4")).true?
    refute evaluate(%("5" != 5)).true?
    refute evaluate(%(6 != "6")).true?
  end

  def test_booleans_and_numbers
    assert evaluate(%(3 > 5 != 1)).true?
    refute evaluate(%(5 < 3 != 0)).true?
  end
end
