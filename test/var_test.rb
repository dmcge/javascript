require "test_helper"

class VarTest < Javascript::Test
  def test_declaring_a_variable
    assert evaluate("var foo")
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
  end
end
