require "test_helper"

class BinaryStrictEqualityTest < Javascript::Test
  def test_operands_of_same_type
    assert evaluate("0 === 0").true?
    refute evaluate("1 === 2").true?
  end

  def test_operands_of_different_types
    refute evaluate(%("1" === 1)).true?
    refute evaluate(%(5 < "3" === 0)).true?
  end

  def test_zero
    assert evaluate("0 === 0").true?
    assert evaluate("-0 === -0").true?
    assert evaluate("0 === -0").true?
    assert evaluate("-0 === 0").true?
  end

  def test_nan
    refute evaluate(%(+"NaN" === +"NaN")).true?
    refute evaluate(%(-"NaN" === -"NaN")).true?
    refute evaluate(%(+"NaN" === -"NaN")).true?
    refute evaluate(%(-"NaN" === +"NaN")).true?
  end
end
