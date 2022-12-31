require "test_helper"

class StringTest < Javascript::Test
  def test_adding_strings_together
    assert_equal "Helloworld", evaluate(%("Hello" + "world"))
    assert_equal "Hello world", evaluate(%("Hello" + " " + "world"))
  end

  def test_adding_strings_with_numbers
    assert_equal "a1", evaluate(%("a" + 1))
    assert_equal "2b", evaluate(%(2 + 'b'))
    assert_equal "c3.14159", evaluate(%("c" + 3.14159))
    assert_equal "4d", evaluate(%(4.0 + 'd'))
  end
end
