require "test_helper"

class BinaryStrictInequalityTest < Javascript::Test
  def test_operands_of_same_type
    assert evaluate("1 !== 2").true?
    refute evaluate("0 !== 0").true?
  end

  def test_operands_of_different_types
    assert evaluate(%("1" !== 5)).true?
    assert evaluate(%("1" !== 1)).true?
    assert evaluate(%(3 > 5 !== 0)).true?
  end
end
