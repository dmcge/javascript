require "test_helper"

class StringTest < Javascript::Test
  def test_adding_strings_together
    assert_equal "Helloworld", evaluate(%("Hello" + "world"))
    assert_equal "Hello world", evaluate(%("Hello" + ' ' + "world"))
  end

  def test_adding_strings_with_numbers
    assert_equal "a1", evaluate(%("a" + 1))
    assert_equal "2b", evaluate(%(2 + 'b'))
    assert_equal "c3.14159", evaluate(%("c" + 3.14159))
    assert_equal "4d", evaluate(%(4.0 + 'd'))
  end

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

  def test_subtracting
    assert_equal 4, evaluate(%("14" - "10"))
    assert_equal 3, evaluate(%("10" - 7))
    assert_equal 2, evaluate(%(6 - '4'))

    assert_equal Float::NAN, evaluate(%("a" - 8))
    assert_equal Float::NAN, evaluate(%("b" - "c"))
    assert_equal Float::NAN, evaluate(%(9 - "d"))
  end

  def test_multiplying
    assert_equal 15, evaluate(%("3" * "5"))
    assert_equal 24, evaluate(%("4" * 6))
    assert_equal -35, evaluate(%(-5 * '7'))

    assert_equal Float::NAN, evaluate(%("a" * 8))
    assert_equal Float::NAN, evaluate(%("b" * "c"))
    assert_equal Float::NAN, evaluate(%(9 * "d"))
  end

  def test_dividing
    assert_equal 3, evaluate(%("15" / "5"))
    assert_equal 4, evaluate(%("24" / 6))
    assert_equal 5, evaluate(%(35 / '7'))

    assert_equal Float::NAN, evaluate(%("a" / 8))
    assert_equal Float::NAN, evaluate(%("b" / "c"))
    assert_equal Float::NAN, evaluate(%(9 / "d"))
  end

  def test_exponentiating
    assert_equal 243, evaluate(%("3" ** "5"))
    assert_equal 4096, evaluate(%("4" ** 6))
    assert_equal 78125, evaluate(%(5 ** '7'))

    assert_equal Float::NAN, evaluate(%("a" ** 8))
    assert_equal Float::NAN, evaluate(%("b" ** "c"))
    assert_equal Float::NAN, evaluate(%(9 ** "d"))
  end

  def test_modulus
    assert_equal 1, evaluate(%("16" % "5"))
    assert_equal 2, evaluate(%("26" % 4))
    assert_equal 5, evaluate(%(35 % '6'))

    assert_equal Float::NAN, evaluate(%("a" % 8))
    assert_equal Float::NAN, evaluate(%("b" % "c"))
    assert_equal Float::NAN, evaluate(%(9 % "d"))
  end

  def test_shifting_left
    assert_equal 0b100100, evaluate(%("0b1001" << "2"))
    assert_equal 0b101010, evaluate(%("0b10101" << 33))
    assert_equal -0b11101000, evaluate(%(-0b11101 << "3"))

    assert_equal 0, evaluate(%("Infinity" << 12))
  end

  def test_shifting_right
    assert_equal 0b10, evaluate(%("0b1001" >> "2"))
    assert_equal 0b1010, evaluate(%("0b10101" >> 33))
    assert_equal -0b100, evaluate(%(-0b11101 >> "3"))

    assert_equal 0, evaluate(%("Infinity" >> 12))
  end

  def test_shifting_right_unsigned
    assert_equal 0b10, evaluate(%("0b1001" >>> "2"))
    assert_equal 0, evaluate(%("0b10101" >>> -33))
    assert_equal 0b11111111111111111111111111100, evaluate(%(-0b11101 >>> "3"))

    assert_equal 0, evaluate(%("Infinity" >>> 12))
  end
end
