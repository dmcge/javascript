require "test_helper"

class TypeOfTest < Javascript::Test
  def test_string
    assert_equal "string", evaluate(%(typeof "hello!"))
  end

  def test_number
    assert_equal "number", evaluate(%(typeof 1))
    assert_equal "number", evaluate(%(typeof 3.14159))
    assert_equal "number", evaluate(%(typeof 0xb4dd00d))
    assert_equal "number", evaluate(%(typeof 45.3e3))
  end

  def test_boolean
    assert_equal "boolean", evaluate(%(typeof true))
    assert_equal "boolean", evaluate(%(typeof false))
  end

  def test_array
    assert_equal "object", evaluate(%(typeof [ 1, 2, 3 ]))
  end

  def test_object
    assert_equal "object", evaluate(%(typeof { a: 1, b: 2 }))
  end

  def test_function
    assert_equal "function", evaluate(%(typeof function sum() {}))
  end

  def test_null
    assert_equal "object", evaluate(%(typeof null))
  end

  def test_variable_reference
    assert_equal "object", evaluate(<<~JS)
      var a = {}
      typeof a
    JS
  end

  def test_uninitialized_variable
    assert_equal "undefined", evaluate(<<~JS)
      var a
      typeof a
    JS
  end

  def test_undeclared_variable
    assert_equal "undefined", evaluate(%(typeof a))
  end
end
