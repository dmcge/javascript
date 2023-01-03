require "test_helper"

class BinaryPrecedenceTest < Javascript::Test
  def test_bodmas
    assert_equal 14, evaluate("2 + 3 * 4")
    assert_equal 20, evaluate("(2 + 3) * 4")
    assert_equal 31, evaluate("7 * 4 + 6 / 2")
    assert_equal 84, evaluate("7 * 4 * 6 / 2")
    assert_equal 50, evaluate("100 ** 1/2")
    assert_equal 10, evaluate("100 ** (1/2)")
  end
end
