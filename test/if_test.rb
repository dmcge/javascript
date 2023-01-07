require "test_helper"

class IfTest < Javascript::Test
  def test_true_condition
    assert_equal "true", evaluate(<<~JS)
      if (2 < 3) {
        "true"
      }
    JS
  end

  def test_truthy
    assert_equal "truthy", evaluate(<<~JS)
      if (2) {
        "truthy"
      }
    JS
  end

  def test_falsey
    assert_nil evaluate(<<~JS)
      if ("") {
        "truthy"
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

  def test_else_true
    assert_equal "phew!", evaluate(<<~JS)
      if (0 > 5) {
        "lies!"
      } else {
        "phew!"
      }
    JS
  end

  def test_else_false
    assert_equal "yes", evaluate(<<~JS)
      if (0 < 5) {
        "yes"
      } else {
        "no"
      }
    JS
  end

  def test_else_if
    assert_equal "yes!", evaluate(<<~JS)
      if (0 > 5) {
        "lies!"
      } else if (0 > -5) {
        "yes!"
      }
    JS
  end

  def test_else_if_else
    assert_equal "finally", evaluate(<<~JS)
      if (0 > 5) {
        "lies"
      } else if (1 > 5) {
        "nope"
      } else {
        "finally"
      }
    JS
  end
end
