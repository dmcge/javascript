require "test_helper"

class ConstTest < Javascript::Test
  def test_declaring_a_variable
    assert_valid "const foo = 'bar'"
    assert_malformed "const a"
  end

  def test_declaring_multiple_variables
    assert_valid "const he = 1, she = 2, them = 3"
    assert_malformed "const he, she, them"
  end

  def test_referencing_a_variable
    assert_equal "A long, long time ago.", evaluate(<<~JS)
      const story = "A long, long time ago"
      story + "."
    JS

    assert_equal 6, evaluate(<<~JS)
      const a = 1, b = 2, c = 3
      a + b + c
    JS
  end

  def test_referencing_a_variable_called_const
    assert_malformed <<~JS
      var const = 1
      const + 2
    JS
  end

  def test_assigning
    assert_raises do
      evaluate(<<~JS.chomp)
        const a = 1
        a += 1
      JS
    end
  end

  def test_redeclaring_consts
    assert_malformed(<<~JS)
      const count = 1
      const count = 2
    JS
  end

  def test_redeclaring_vars
    assert_malformed(<<~JS)
      var count = 1
      const count = 2
    JS
  end

  def test_redeclaring_lets
    assert_malformed(<<~JS)
      let count = 1
      const count = 2
    JS
  end

  def test_redeclaring_variables_in_differents_scopes
    assert_valid(<<~JS)
      if (true) {
        const value = "true"
      } else {
        const value = "false"
      }
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
        const string = "all the way down here!"
      JS
    end
  end

  def test_assigning_a_variable_before_it_is_declared
    assert_raises do
      evaluate(<<~JS)
        string = "beat you!"
        const string
      JS
    end
  end

  def test_shadowing_an_outer_variable
    assert_raises do
      evaluate(<<~JS)
        var message = "var"

        if (true) {
          message
          const message = "const"
        }
      JS
    end
  end

  def test_scoping_to_a_block
    assert_raises do
      evaluate(<<~JS)
        if (true) {
          const value = "true"
        } else {
          const value = "false"
        }

        value
      JS
    end
  end

  def test_dangling_equals
    assert_malformed "const remember ="
  end
end
