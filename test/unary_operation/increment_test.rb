require "test_helper"

class UnaryIncrementTest < Javascript::Test
  def test_prefix_incrementing
    assert_equal 1, evaluate(<<~JS.chomp)
      var count = 0
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
    assert_malformed "++1"
    assert_malformed %(++"foo")

    assert_malformed "2++"
    assert_malformed %("bar"++)
  end
end
