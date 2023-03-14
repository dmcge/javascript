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

  def test_special_character_escapes
    assert_equal "\n", evaluate("`\\n`")
    assert_equal "\r", evaluate("`\\r`")
    assert_equal "\t", evaluate("`\\t`")
    assert_equal "\b", evaluate("`\\b`")
    assert_equal "\f", evaluate("`\\f`")
    assert_equal "\v", evaluate("`\\v`")
    assert_equal "\0", evaluate("`\\0`")
  end

  def test_4hex_unicode_escapes
    assert_equal "\r", evaluate("`\\u000d`")
    assert_equal "¿", evaluate("`\\u00bf`")
    assert_equal "ò", evaluate("`\\u00F2`")
    assert_equal "b\ro", evaluate("`b\\u000do`")

    assert_malformed "`\\u`"
    assert_malformed "`\\ud`"
    assert_malformed "`\\u0d`"
    assert_malformed "`\\u00d`"
  end

  def test_aribtrary_unicode_escapes
    assert_equal "\r", evaluate("`\\u{d}`")
    assert_equal "a", evaluate("`\\u{61}`")
    assert_equal "∫", evaluate("`\\u{222b}`")
    assert_equal "􀐏", evaluate("`\\u{10040F}`")
    assert_equal "abc", evaluate("`a\\u{62}c`")

    assert_malformed "\\u{}"
    assert_malformed "\\u{11FFFF}"
    assert_malformed '\\u{100FFFF}'
  end

  def test_hex_escape
    assert_equal "\r", evaluate("`\\x0d`")
    assert_equal "¿", evaluate("`\\xbf`")
    assert_equal "ò", evaluate("`\\xF2`")
    assert_equal "abc", evaluate("`a\\x62c`")

    assert_malformed "`\\x`"
    assert_malformed "`\\xd`"
  end

  def test_octal_escape
    assert_equal "1", evaluate("`\\1`")
    assert_equal "2", evaluate("`\\2`")
    assert_equal "3", evaluate("`\\3`")
    assert_equal "4", evaluate("`\\4`")
    assert_equal "5", evaluate("`\\5`")
    assert_equal "6", evaluate("`\\6`")
    assert_equal "7", evaluate("`\\7`")

    assert_equal "8", evaluate("`\\8`")
    assert_equal "08", evaluate("`\\08`")
    assert_equal "09", evaluate("`\\09`")
  end

  def test_arbitrary_escapes
    assert_equal "a", evaluate("`\\a`")
    assert_equal "⌘", evaluate("`\\⌘`")
    assert_equal "👨‍👩‍👧", evaluate("`\\👨‍👩‍👧`")
  end

  def test_dangling_escapes
    assert_equal " ", evaluate("`\ `")
    assert_malformed "`\\`"
  end
end
