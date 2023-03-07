require "test_helper"

class VoidTest < Javascript::Test
  def test_overriding_expressions
    assert_nil evaluate(<<~JS)
      const output = void 1;
      output
    JS
  end

  def test_precedence
    refute evaluate(%(void 2 === "2")).truthy?
    assert_nil evaluate(%(void (2 === "2")))
  end
end
