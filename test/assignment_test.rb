require "test_helper"

class AssignmentTest < Javascript::Test
  def test_addition_assignment
    assert_equal 4, evaluate_assignment(1, "+= 3")
    assert_equal "a3", evaluate_assignment(%("a"), "+= 3")
    assert_equal "ab", evaluate_assignment(%("a"), %(+= "b"))
    assert_equal 6, evaluate_assignment("[]", "+= 6")
  end

  def test_subtraction_assignment
    assert_equal -2, evaluate_assignment(1, "-= 3")
    assert_equal 1, evaluate_assignment(%("4"), "-= 3")
    assert evaluate_assignment(%("a"), %(-= "b")).nan?
    assert_equal -6, evaluate_assignment("[]", "-= 6")
  end

  def test_multiplication_assignment
    assert_equal 3, evaluate_assignment(1, "*= 3")
    assert_equal 12, evaluate_assignment(%("4"), "*= 3")
    assert evaluate_assignment(%("a"), %(*= "b")).nan?
    assert_equal 0, evaluate_assignment("[]", "*= 6")
  end

  def test_division_assignment
    assert_equal 2, evaluate_assignment(6, "/= 3")
    assert_equal 2.5, evaluate_assignment(%("5"), "/= 2")
    assert evaluate_assignment(%("a"), %(/= "b")).nan?
    assert_equal 0, evaluate_assignment("[]", "/= 6")
    assert_equal Float::INFINITY, evaluate_assignment("99", "/= 0")
  end

  def test_exponentiation_assignment
    assert_equal 1, evaluate_assignment(1, "**= 3")
    assert_equal 64, evaluate_assignment(%("4"), "**= 3")
    assert evaluate_assignment(%("a"), %(**= "b")).nan?
    assert_equal 0, evaluate_assignment("[]", "**= 6")
  end

  def test_modulo_assignment
    assert_equal 2, evaluate_assignment(2, "%= 3")
    assert_equal 1, evaluate_assignment(%("4"), "%= 3")
    assert evaluate_assignment(%("a"), %(%= "b")).nan?
    assert_equal 0, evaluate_assignment("[]", "%= 6")
  end

  def test_left_shift_assignment
    assert_equal 0b1000, evaluate_assignment(1, "<<= 3")
    assert_equal 0b100, evaluate_assignment(%("2"), "<<= 1")
    assert_equal 0, evaluate_assignment(%("a"), %(<<= "b"))
    assert_equal 0, evaluate_assignment("[]", "<<= 6")
  end

  def test_right_shift_assignment
    assert_equal 1, evaluate_assignment(0b1111, ">>= 3")
    assert_equal 0b10, evaluate_assignment(%("0b1010"), ">>= 2")
    assert_equal 0, evaluate_assignment(%("a"), %(>>= "b"))
    assert_equal 0, evaluate_assignment("[]", ">>= 6")
  end

  def test_right_shift_unsigned_assignment
    assert_equal 0b11111111111111111111111111110, evaluate_assignment(-0b1111, ">>>= 3")
    assert_equal 0b111111111111111111111111111101, evaluate_assignment(%(-"0b1010"), ">>>= 2")
    assert_equal 0, evaluate_assignment(%("a"), %(>>>= "b"))
    assert_equal 0, evaluate_assignment("[]", ">>>= 6")
  end

  def test_bitwise_and_assignment
    assert_equal 1, evaluate_assignment(0b11, "&= 0b0101")
    assert_equal 4, evaluate_assignment(%("4"), "&= 0b11101")
    assert_equal 0, evaluate_assignment(%("a"), %(&= "b"))
    assert_equal 0, evaluate_assignment("[]", "&= 6")
  end

  def test_bitwise_or_assignment
    assert_equal 0b1111, evaluate_assignment(0b111, "|= 0b1010")
    assert_equal 0b110101, evaluate_assignment(%("4"), "|= 0b110101")
    assert_equal 0, evaluate_assignment(%("a"), %(|= "b"))
    assert_equal 6, evaluate_assignment("[]", "|= 6")
  end

  def test_bitwise_xor_assignment
    assert_equal 0b1101, evaluate_assignment(0b111, "^= 0b1010")
    assert_equal 0b110001, evaluate_assignment(%("4"), "^= 0b110101")
    assert_equal 0, evaluate_assignment(%("a"), %(^= "b"))
    assert_equal 6, evaluate_assignment("[]", "^= 6")
  end

  def test_and_assignment
    skip
  end

  def test_or_assignment
    skip
  end

  private
    def evaluate_assignment(left, infix)
      evaluate(<<~JS.chomp)
        var a = #{left}
        a #{infix}
        a
      JS
    end
end
