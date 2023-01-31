require "test_helper"

class UnaryIncrementTest < Javascript::Test
  def test_prefix_incrementing
    assert_equal 1, evaluate(<<~JS.chomp)
      var count = 0; // FIXME: the semicolon should be inserted here automatically
      ++count
    JS
  end

  def test_postfix_incrementing
    assert_equal 0, evaluate(<<~JS.chomp)
      var count = 0
      count++
    JS
  end

  def test_incrementing_a_literal
    assert_invalid "++1"
    assert_invalid %(++"foo")

    assert_invalid "2++"
    assert_invalid %("bar"++)
  end
end
