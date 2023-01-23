require "test_helper"

class NullLiteralsTest < Javascript::Test
  def test_null
    assert_valid "var test = null"
  end
end
