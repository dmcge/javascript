require "test_helper"

class StringTest < Javascript::Test
  def test_converting_to_number
    assert_equal 0, evaluate(%(+""))
    assert_equal 0, evaluate(%(+"0"))
    assert_equal -12, evaluate(%(-"12"))
    assert_equal 3.14159, evaluate(%(+"3.14159"))

    assert_equal 2.71828, evaluate(%(+"+2.71828"))
    assert_equal -2.71828, evaluate(%(+"-2.71828"))
    assert_equal -2.71828, evaluate(%(-"+2.71828"))
    assert_equal 2.71828, evaluate(%(-"-2.71828"))

    assert_equal 0.71828, evaluate(%(+".71828"))
    assert_equal -4e2, evaluate(%(-"4e2"))
    assert_equal 0xb4dd00d, evaluate(%(+"0xb4dd00d"))

    assert_equal Float::INFINITY, evaluate(%(+"Infinity"))
    assert_equal Float::INFINITY, evaluate(%(+"+Infinity"))
    assert_equal -Float::INFINITY, evaluate(%(+"-Infinity"))
    assert_equal -Float::INFINITY, evaluate(%(-"Infinity"))
    assert_equal -Float::INFINITY, evaluate(%(-"+Infinity"))
    assert_equal Float::INFINITY, evaluate(%(-"-Infinity"))

    assert_equal Float::NAN, evaluate(%(+"infinity"))
    assert_equal Float::NAN, evaluate(%(+"-infinity"))

    assert_equal 3.14159, evaluate(%(+"3.14159    "))
    assert_equal 0b1010101, evaluate(%(+"            0b1010101"))
    assert_equal 4e2, evaluate(%(+"\\r4e2\\n"))
    assert_equal 0, evaluate(%(+" \t\\f"))

    assert_equal Float::NAN, evaluate(%(+"ab"))
    assert_equal Float::NAN, evaluate(%(+"12."))
    assert_equal Float::NAN, evaluate(%(+"12.2E"))
    assert_equal Float::NAN, evaluate(%(+" 10 10 101 "))

    # TODO: what about _ separators
  end
end
