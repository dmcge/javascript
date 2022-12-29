require "test_helper"

class SyntaxTest < Javascript::Test
  def test_syntactic_boundaries
    assert_equal 2, evaluate("1; 2")
    assert_equal 4, evaluate("3\n4")
    assert_raises { evaluate("5 6") }
  end
end
