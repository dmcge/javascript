require "test_helper"

class SyntaxTest < Javascript::Test
  def test_syntactic_boundaries
    assert_equal 2, evaluate("1; 2")
    assert_equal 4, evaluate("3\n4")
    assert_malformed "5 6"
  end

  def test_dangling_operators
    assert_malformed "+"
    assert_malformed "3 *"
    assert_malformed "/ 2"
  end

  def test_multiline_expression
    assert_equal 5, evaluate("2 +\n 3")
  end

  def test_empty_parentheticals
    assert_malformed "()"
    assert_malformed "() * 7"
    assert_malformed "3 / ()"
  end
end
