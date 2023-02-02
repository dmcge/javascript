require "test_helper"

class UnaryDecrementTest < Javascript::Test
  def test_prefix_decrementing
    assert_equal 0, evaluate(<<~JS.chomp)
      var count = 1
      --count
    JS
  end

  def test_postfix_decrementing
    assert_equal 1, evaluate(<<~JS.chomp)
      var count = 1
      count--
    JS
  end

  def test_decrementing_a_literal
    assert_malformed "--1"
    assert_malformed %(--"foo")

    assert_malformed "2--"
    assert_malformed %("bar"--)
  end
end
