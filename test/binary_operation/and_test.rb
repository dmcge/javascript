require "test_helper"

class BinaryAndTest < Javascript::Test
  def test_both_sides_are_truthy
    assert_equal 2, evaluate("1 && 2")
    assert_equal "a", evaluate(%(true && "a"))
  end

  def test_left_hand_side_is_falsey
    assert_equal 0, evaluate(%(0 && 5))
    assert_equal "", evaluate(%("" && true))

    assert_equal 0, evaluate(<<~JS.chomp)
      var i = 0
      i && i++
      i
    JS
  end

  def test_left_hand_side_is_truthy
    assert_equal "", evaluate(%(1 && ""))
    assert_equal 0, evaluate(%(true && 0))

    assert_equal 2, evaluate(<<~JS.chomp)
      var i = 1
      i && i++
      i
    JS
  end
end
