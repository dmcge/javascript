require "test_helper"

class WhileTest < Javascript::Test
  def test_looping
    assert_equal 5, evaluate(<<~JS.chomp)
      let a = 0

      while (a < 5) {
        a += 1
      }

      a
    JS
  end

  def test_false_condition
    assert_equal 0, evaluate(<<~JS.chomp)
      let a = 0

      while (a > 5) {
        a += 1
      }

      a
    JS
  end
end
