require "test_helper"

class IfTest < Javascript::Test
  def test_true_condition
    assert_equal "true", evaluate(<<~JS)
      if (2 < 3) {
        "true"
      }
    JS
  end

  def test_false_condition
    assert_nil evaluate(<<~JS)
      if (0 > 5) {
        "lies!"
      }
    JS
  end
end
