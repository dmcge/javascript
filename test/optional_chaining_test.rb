require "test_helper"

class OptionalChainingTest < Javascript::Test
  def test_dot_accessor
    assert_equal 10, evaluate(<<~JS)
      var number = { exponent: { base: 10 } }
      number?.exponent?.base
    JS

    assert_undefined evaluate(<<~JS)
      var number = {}
      number?.exponent?.base
    JS
  end

  def test_square_bracket_accessor
    assert_equal 10, evaluate(<<~JS)
      var number = { exponent: { base: 10 } }
      number?.["exponent"]?.["base"]
    JS

    assert_undefined evaluate(<<~JS)
      var number = {}
      number?.["exponent"]?.["base"]
    JS
  end

  def test_function_calls
    assert_equal 10, evaluate(<<~JS)
      var number = { exponent: { format() { return 10 } } }
      number?.exponent?.format?.()
    JS

    assert_undefined evaluate(<<~JS)
      var number = {}
      number?.exponent?.format?.()
    JS
  end

  def test_incomplete_chain
    assert_raises { evaluate(<<~JS) }
      var number = {}
      number?.exponent.base
    JS
  end

  def test_no_chaining_with_number_literals
    assert_equal 0.2, evaluate("true?.2:.3")
  end

  private
    def assert_undefined(value)
      assert value.is_a?(Javascript::Undefined)
    end
end
