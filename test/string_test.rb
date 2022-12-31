require "test_helper"

class StringTest < Javascript::Test
  def test_adding_strings_together
    assert_equal "Helloworld", evaluate(%("Hello" + "world"))
    assert_equal "Hello world", evaluate(%("Hello" + " " + "world"))
  end
end
