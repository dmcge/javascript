require "test_helper"

class SyntaxTest < Javascript::Test
  def test_syntactic_boundaries
    assert_equal 2, evaluate("1; 2")
    assert_equal 4, evaluate("3\n4")
    assert_invalid "5 6"
  end

  def test_multiline_expression
    assert_equal 5, evaluate("2 +\n 3")
  end

  def test_empty_parentheticals
    assert_invalid "()"
    assert_invalid "() * 7"
    assert_invalid "3 / ()"
  end
end
