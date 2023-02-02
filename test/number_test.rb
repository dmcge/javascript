require "test_helper"

class NumberTest < Javascript::Test
  def test_minimum
    assert_equal -1.7976931348623157e308, evaluate("-1.7976931348623157e308")
    assert_equal -1.7976931348623157e308, evaluate("-1.7976931348623158e308")
    assert_equal -Float::INFINITY, evaluate("-1.7976931348623159e308")
    assert_equal -Float::INFINITY, evaluate("-1.1897314953572317650857593266280070162e4932")
  end

  def test_maximum
    assert_equal 1.7976931348623157e308, evaluate("1.7976931348623157e308")
    assert_equal 1.7976931348623157e308, evaluate("1.7976931348623158e308")
    assert_equal Float::INFINITY, evaluate("1.7976931348623159e308")
    assert_equal Float::INFINITY, evaluate("1.1897314953572317650857593266280070162e4932")
  end

  def test_maximum_precision
    assert_equal 1.0000000000000002, evaluate("1.0000000000000002")
    assert_equal 1, evaluate("1.0000000000000001")
  end
end
