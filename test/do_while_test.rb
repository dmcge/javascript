require "test_helper"

class DoWhileTest < Javascript::Test
  def test_looping
    assert_equal 5, evaluate(<<~JS.chomp)
      let a = 0

      do {
        a += 1
      } while (a < 5)

      a
    JS
  end

  def test_false_condition
    assert_equal 1, evaluate(<<~JS.chomp)
      let a = 0

      do {
        a += 1
      } while (a > 5)

      a
    JS
  end
end
