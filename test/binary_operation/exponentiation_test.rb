require "test_helper"

class BinaryAdditionTest < Javascript::Test
  def test_exponentiating_numbers
    assert_equal 100, evaluate("10 ** 2")
    assert_equal 10, evaluate("100 ** 0.5")
    assert_equal 0.01, evaluate("100 ** -1")
  end

  def test_associativity
    assert_equal 2 ** (4 ** 3), evaluate("2 ** 4 ** 3")
  end

  def test_exponentiating_numeric_strings
    assert_equal 243, evaluate(%("3" ** "5"))
    assert_equal 4096, evaluate(%("4" ** 6))
    assert_equal 78125, evaluate(%(5 ** '7'))
  end

  def test_exponentiating_non_numeric_strings
    assert evaluate(%("a" ** 8)).nan?
    assert evaluate(%("b" ** "c")).nan?
    assert evaluate(%(9 ** "d")).nan?
  end
end
