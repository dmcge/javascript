require "test_helper"

class BooleanLiteralsTest < Javascript::Test
  def test_true
    assert evaluate("true").true?
    assert evaluate("true").truthy?
  end

  def test_false
    refute evaluate("false").true?
    refute evaluate("false").truthy?
  end
end
