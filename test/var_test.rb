require "test_helper"

class VarTest < Javascript::Test
  def test_declaring_a_variable
    assert_valid "var a"
    assert_valid "var text"
    assert_valid "var foo = 'bar'"
  end

  def test_declaring_multiple_variables
    assert_valid "var he, she, them"
    assert_valid "var he = 1, she = 2, them = 3"
  end

  def test_referencing_a_variable
    assert_equal "A long, long time ago.", evaluate(<<~JS)
      var story = "A long, long time ago"
      story + "."
    JS

    assert_equal 6, evaluate(<<~JS)
      var a = 1, b = 2, c = 3
      a + b + c
    JS
  end

  def test_assigning_to_another_variable
    assert_equal 1, evaluate(<<~JS.chomp)
      var a, b
      a = 1
      b = a
      a++
      b
    JS
  end

  def test_variable_names
    assert_valid "var $"
    assert_valid "var _"
    assert_valid "var ᪧῼ"

    assert_valid "var abc123"
    assert_valid "var bengali_six_৫"
    assert_malformed "var 1"
    assert_malformed "var 123456"
    assert_malformed "var ৫"

    assert_valid "var well\u200d"
    assert_malformed "var \u200dd"

    assert_valid "var fඃd"
    assert_malformed "var ඃ"

    assert_valid "var iffy"
    assert_valid "var elsewhere"
    assert_malformed "var if"
  end

  def test_redeclaring_variables
    assert_equal 2, evaluate(<<~JS)
      var count = 1
      var count = 2
      count
    JS
  end

  def test_reassigning_variables
    assert_equal 2, evaluate(<<~JS)
      var count = 1
      count = 2
      count
    JS
  end

  def test_referencing_a_variable_before_it_is_declared
    assert_raises { evaluate("record") }
    assert_raises { evaluate("record = 1") }
  end

  def test_dangling_equals
    assert_malformed "var remember ="
  end
end
