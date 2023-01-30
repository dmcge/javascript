require "test_helper"

class BinaryOrTest < Javascript::Test
  def test_both_sides_are_truthy
    assert_equal 1, evaluate("1 || 2")
    assert_equal "a", evaluate(%("a" || true))
  end

  def test_left_hand_side_is_falsey
    assert_equal 5, evaluate(%(0 || 5))
    assert_equal "true", evaluate(%("" || "true"))

    assert_equal 1, evaluate(<<~JS.chomp)
      var i = 0
      i || i++
      i
    JS
  end

  def test_left_hand_side_is_truthy
    assert_equal 1, evaluate(%(1 || ""))
    assert_equal "true", evaluate(%("true" || true))

    assert_equal 1, evaluate(<<~JS.chomp)
      var i = 1
      i || i++
      i
    JS
  end
end
