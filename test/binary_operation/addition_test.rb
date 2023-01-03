require "test_helper"

class BinaryAdditionTest < Javascript::Test
  def test_adding_numbers
    assert_equal 4, evaluate("1 + 1 + 2")
    assert_equal 4294967297, evaluate("2274827419 + 2020139878")
    assert_equal 4.5, evaluate("1.1 + 3.4")
  end

  def test_adding_strings_together
    assert_equal "Helloworld", evaluate(%("Hello" + "world"))
    assert_equal "Hello world", evaluate(%("Hello" + ' ' + "world"))
    assert_equal "34", evaluate(%("3" + "4"))
  end

  def test_adding_strings_and_numbers
    assert_equal "a1", evaluate(%("a" + 1))
    assert_equal "2b", evaluate(%(2 + 'b'))
    assert_equal "c3.14159", evaluate(%("c" + 3.14159))
    assert_equal "4d", evaluate(%(4.0 + 'd'))
  end

  def test_adding_with_negative_numbers
    assert_equal 1, evaluate("-1 + 2")
    assert_equal -1, evaluate("1 + -2")
    assert_equal -3, evaluate("-1 + -2")
  end
end
