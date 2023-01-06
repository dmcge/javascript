require "test_helper"

class BinaryInequalityTest < Javascript::Test
  def test_operands_of_same_type
    assert evaluate("1 != 2")
    refute evaluate("0 != 0")
  end

  def test_strings_and_numbers
    assert evaluate(%("1" != 2))
    assert evaluate(%(3 != "4"))
    refute evaluate(%("5" != 5))
    refute evaluate(%(6 != "6"))
  end

  def test_booleans_and_numbers
    skip
    assert evaluate(%(3 > 5 != 1))
    refute evaluate(%(5 < 3 != 0))
  end
end
