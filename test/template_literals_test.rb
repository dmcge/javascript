require "test_helper"

class TemplateLiteralsTest < Javascript::Test
  def test_no_substitution
    assert_equal "hello", evaluate("`hello`")
  end

  def test_substitution
    assert_equal "zayna, howdy", evaluate(%(`${"zayna"}, howdy`))
    assert_equal "hello, jon!", evaluate(%(`hello, ${"jon"}!`))
    assert_equal "goodbye, izzy", evaluate(%(`goodbye, ${"izzy"}`))
  end

  def test_substitution_with_non_string_values
    assert_equal "34", evaluate(%(`${34}`))
    assert_equal "10,20", evaluate(%(`${[10, 20]}`))
    assert_equal "[object Object]", evaluate(%(`${{ a: 1, b: 2 }}`))
  end

  def substitution_with_variables
    assert_equal "hello, jon!", evaluate(<<~JS)
      let name = "jon"
      `hello, ${name}!`
    JS
  end

  def substitution_with_multiple_expressions
    assert_malformed "`${3 4}`"
    assert_malformed "`${1; 2}`"
  end

  def test_empty
    assert_equal "", evaluate("``")
  end

  def test_never_ending
    assert_malformed "`abc"
    assert_malformed "`12${3`"
  end

  # line breaks aren’t allowed in string literals but are in template literals
  def test_line_breaks
    assert_equal "s\nb\n", evaluate(<<~JS)
      `s
      b
      `
    JS
  end

  def test_line_continuation
    assert_equal "sb\n", evaluate(<<~JS)
      `s\\
      b
      `
    JS
  end
end
