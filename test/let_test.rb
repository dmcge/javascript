require "test_helper"

class LetTest < Javascript::Test
  def test_declaring_a_variable
    assert_valid "let a"
    assert_valid "let text"
    assert_valid "let foo = 'bar'"
  end

  def test_declaring_multiple_variables
    assert_valid "let he, she, them"
    assert_valid "let he = 1, she = 2, them = 3"
  end

  def test_referencing_a_variable
    assert_equal "A long, long time ago.", evaluate(<<~JS)
      let story = "A long, long time ago"
      story + "."
    JS

    assert_equal 6, evaluate(<<~JS)
      let a = 1, b = 2, c = 3
      a + b + c
    JS
  end

  def test_assigning_to_another_variable
    assert_equal 1, evaluate(<<~JS.chomp)
      let a, b
      a = 1
      b = a
      a++
      b
    JS
  end

  def test_variable_names
    assert_valid "let $"
    assert_valid "let _"
    assert_valid "let ᪧῼ"

    assert_malformed "let let"

    assert_valid "let abc123"
    assert_valid "let bengali_six_৫"
    assert_malformed "let 1"
    assert_malformed "let 123456"
    assert_malformed "let ৫"

    assert_valid "let well\u200d"
    assert_malformed "let \u200dd"

    assert_valid "let fඃd"
    assert_malformed "let ඃ"

    assert_valid "let iffy"
    assert_valid "let elsewhere"
    assert_malformed "let if"
  end

  def test_redeclaring_variables
    assert_malformed(<<~JS)
      let count = 1
      let count = 2
      count
    JS
  end

  def test_redeclaring_variables_in_differents_scopes
    assert_valid(<<~JS)
      if (true) {
        let value = "true"
      } else {
        let value = "false"
      }
    JS
  end

  def test_reassigning_variables
    assert_equal 2, evaluate(<<~JS)
      let count = 1
      count = 2
      count
    JS
  end

  def test_referencing_a_variable_that_is_never_declared
    assert_raises { evaluate("record") }
    assert_raises { evaluate("record = 1") }
  end

  def test_referencing_a_variable_before_it_is_declared
    assert_raises do
      evaluate(<<~JS)
        string
        let string = "all the way down here!"
      JS
    end
  end

  def test_assigning_a_variable_before_it_is_declared
    assert_raises do
      evaluate(<<~JS)
        string = "beat you!"
        let string
      JS
    end
  end

  def test_shadowing_an_outer_variable
    assert_raises do
      evaluate(<<~JS)
        var message = "var"

        if (true) {
          message
          let message = "let"
        }
      JS
    end
  end

  def test_scoping_to_a_block
    assert_raises do
      evaluate(<<~JS)
        if (true) {
          let value = "true"
        } else {
          let value = "false"
        }

        value
      JS
    end
  end

  def test_dangling_equals
    assert_malformed "let remember ="
  end
end
