require "test_helper"

class NumberLiteralsTest < Javascript::Test
  def test_integer_literals
    assert_equal 69, evaluate("69")
    assert_equal 420, evaluate("420")
    assert_equal 981, evaluate("0981")
  end

  def test_decimal_literals
    assert_equal 3.1415, evaluate("3.1415")
    assert_equal 0.2748927492, evaluate("0.2748927492")
    assert_equal 0.728472, evaluate(".728472")
    assert_equal 0.7, evaluate("00.7000")
    assert_raises { evaluate("3.1.415") }
    assert_raises { evaluate(".1.415") }
  end

  def test_hex_literals
    assert_equal 0xb4dd00d, evaluate("0xb4dd00d")
    assert_equal 0xc4bb9e, evaluate("0xc4bb9e")
    assert_equal 0xf, evaluate("0xf")
    assert_equal 0x000e, evaluate("0X000e")

    assert_raises { evaluate("0x") }
    assert_raises { evaluate("0X") }
    assert_raises { evaluate("0xabcg") }
  end

  def test_binary_literals
    assert_equal 0b11001, evaluate("0b11001")
    assert_equal 0b1, evaluate("0b1")
    assert_equal 0b0001, evaluate("0B0001")

    assert_raises { evaluate("0b") }
    assert_raises { evaluate("0B") }
    assert_raises { evaluate("0b111112") }
  end

  def test_octal_literals
    assert_equal 0o77612, evaluate("0o77612")
    assert_equal 0o4, evaluate("0o4")
    assert_equal 0o0000720, evaluate("0O0000720")

    assert_raises { evaluate("0o") }
    assert_raises { evaluate("0O") }
    assert_raises { evaluate("0O12345678") }
  end

  def test_legacy_octal_literals
    assert_equal 0o77612, evaluate("077612")
    assert_equal 0o4, evaluate("04")
    assert_equal 0o0000720, evaluate("00000720")

    assert_equal 0, evaluate("0")
    assert_equal 1.23, evaluate("1.23")
    assert_equal 19, evaluate("019")
  end

  def test_number_separators_with_decimal_literals
    assert_equal 315_242_242_000, evaluate("315_242_242_000")
    assert_equal 420, evaluate("4_20")
    assert_equal 4.2000000, evaluate("4.2_000_000")

    assert_raises { evaluate("345_") }
    assert_raises { evaluate("345_.232") }
    assert_raises { evaluate("345.232_") }
  end

  def test_number_separators_with_binary_literals
    assert_equal 0b110011, evaluate("0b11_00_11")
    assert_raises { evaluate("0b_") }
    assert_raises { evaluate("0b1_") }
  end

  def test_number_separators_with_octal_literals
    assert_equal 0o7001216, evaluate("0o7_001_216")
    assert_raises { evaluate("0o_") }
    assert_raises { evaluate("0o6_") }
  end

  def test_number_separators_with_hex_literals
    assert_equal 0xf70de00a, evaluate("0xf7_0de_00a")
    assert_raises { evaluate("0x_") }
    assert_raises { evaluate("0x6_") }
  end

  def test_signed_literals
    assert_equal 78247, evaluate("+78247")
    assert_equal 782.2424, evaluate("+782.2424")
    assert_equal -2424, evaluate("-2424")
    assert_equal -2.8092, evaluate("-2.8092")

    assert_equal 0, evaluate("-1+1")
    assert_equal 0, evaluate("+1-1")
    assert_equal 0, evaluate("1 + -1")

    # assert_equal 1, evaluate("2 +\n-1")
    # assert_equal 1, evaluate("2 +\n -1")
  end

  def test_exponential_literals
    assert_equal 3e18, evaluate("3e18")
    assert_equal 1.43e9, evaluate("1.43E9")
    assert_raises { evaluate("3e18e1") }
    assert_raises { evaluate("3e18E1") }
  end
end