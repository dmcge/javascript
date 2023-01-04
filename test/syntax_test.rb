require "test_helper"

class SyntaxTest < Javascript::Test
  def test_syntactic_boundaries
    assert_equal 2, evaluate("1; 2")
    assert_equal 4, evaluate("3\n4")
    assert_raises { evaluate("5 6") }
  end

  def test_empty_parentheticals
    assert_raises { evaluate("()") }
    assert_raises { evaluate("() * 7") }
    assert_raises { evaluate("3 / ()") }
  end
end
