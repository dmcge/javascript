require "test_helper"

class VarTest < Javascript::Test
  def test_declaring_a_variable
    assert evaluate("var a")
    assert evaluate("var text")
    assert evaluate("var foo = 'bar'")
  end

  def test_declaring_multiple_variables
    assert evaluate("var he, she, them")
    assert evaluate("var he = 1, she = 2, them = 3")
  end

  def test_referencing_a_variable
    assert_equal "A long, long time ago.", evaluate(<<~JS)
      var story = "A long, long time ago"
      story + "."
    JS

    assert_equal 6, evaluate(<<~JS)
      var a = 1, b = 2, c = 3
      a + b + c
    JS
  end

  def test_variable_names
    assert evaluate("var $")
    assert evaluate("var _")
    assert evaluate("var ᪧῼ")

    assert evaluate("var abc123")
    assert evaluate("var bengali_six_৫")
    assert_raises { evaluate("var 1") }
    assert_raises { evaluate("var 123456") }
    assert_raises { evaluate("var ৫") }

    assert evaluate("var well\u200d")
    assert_raises { evaluate("var \u200dd") }

    assert evaluate("var fඃd")
    assert_raises { evaluate("var ඃ") }

    assert evaluate("var iffy")
    assert evaluate("var elsewhere")
    assert_raises { evaluate("var if") }
  end
end
