require "test_helper"

class BinaryEqualityTest < Javascript::Test
  def test_operands_of_same_type
    assert evaluate("0 == 0")
    refute evaluate("1 == 2")
  end

  def test_strings_and_numbers
    assert evaluate(%("1" == 1))
    assert evaluate(%(2 == "2"))
    refute evaluate(%("3" == 4))
    refute evaluate(%(5 == "6"))
  end

  def test_booleans_and_numbers
    skip
    assert evaluate(%(3 < 5 == 1))
    assert evaluate(%(5 < 3 == 0))
  end
end
