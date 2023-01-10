require "test_helper"

class StringLiteralsTest < Javascript::Test
  def test_double_quotes
    assert_equal "hello", evaluate(%("hello"))
  end

  def test_single_quotes
    assert_equal "goodbye", evaluate(%('goodbye'))
  end

  def test_nested_quotes
    assert_equal "y'all", evaluate(%("y'all"))
    assert_equal "goodbye 'yellow brick road'", evaluate(%("goodbye 'yellow brick road'"))
    assert_equal %(goodbye "yellow brick road"), evaluate(%('goodbye "yellow brick road"'))
  end

  def test_never_ending
    assert_raises { evaluate(%('to me)) }
    assert_raises { evaluate(%("to you)) }
  end

  def test_mismatched_quotes
    assert_raises { evaluate(%('welp")) }
    assert_raises { evaluate(%("welp')) }
  end

  def test_empty_string
    assert_equal "", evaluate(%(""))
    assert_equal "", evaluate(%(''))
  end

  def test_anything_goes
    assert_equal ";", evaluate(%(";"))
    assert_equal "123 undefined if unless", evaluate(%("123 undefined if unless"))
    assert_equal "2uyrtp982uht;i2t8p789[32o", evaluate(%('2uyrtp982uht;i2t8p789[32o'))
    assert_equal "\0", evaluate(%('\0'))
    assert_equal "𓀂", evaluate(%("𓀂"))
    assert_equal "👨‍👩‍👧", evaluate(%('👨‍👩‍👧'))
  end

  def test_strings_written_over_multiple_lines
    assert_equal "hello world", evaluate(%("#{<<~STRING.strip}"))
      hello \\
      world
    STRING
  end

  def test_multline_strings
    assert_raises { evaluate(%("hello\nworld")) }
    assert_raises { evaluate(%("hello\r\nworld")) }
    assert_raises do
      evaluate(%("#{<<~STRING}"))
        hello
        cruel
        world
      STRING
    end
  end

  def test_special_character_escapes
    assert_equal "\n", evaluate(%("\\n"))
    assert_equal "\r", evaluate(%("\\r"))
    assert_equal "\t", evaluate(%('\\t'))
    assert_equal "\b", evaluate(%("\\b"))
    assert_equal "\f", evaluate(%('\\f'))
    assert_equal "\v", evaluate(%("\\v"))
  end

  def test_4hex_unicode_escapes
    assert_equal "\r", evaluate(%("\\u000d"))
    assert_equal "¿", evaluate(%('\\u00bf'))
    assert_equal "ò", evaluate(%("\\u00F2"))
    assert_equal "b\ro", evaluate(%('b\\u000do'))

    assert_raises { evaluate(%("\\u")) }
    assert_raises { evaluate(%("\\ud")) }
    assert_raises { evaluate(%('\\u0d')) }
    assert_raises { evaluate(%("\\u00d")) }
  end

  def test_aribtrary_unicode_escapes
    assert_equal "\r", evaluate(%("\\u{d}"))
    assert_equal "a", evaluate(%('\\u{61}'))
    assert_equal "∫", evaluate(%("\\u{222b}"))
    assert_equal "􀐏", evaluate(%('\\u{10040F}'))
    assert_equal "abc", evaluate(%("a\\u{62}c"))

    assert_invalid "\\u{}"
    assert_invalid "\\u{11FFFF}"
    assert_raises { evaluate('\\u{100FFFF}') }
  end

  def test_hex_escape
    assert_equal "\r", evaluate(%("\\x0d"))
    assert_equal "¿", evaluate(%('\\xbf'))
    assert_equal "ò", evaluate(%("\\xF2"))
    assert_equal "abc", evaluate(%('a\\x62c'))

    assert_raises { evaluate(%("\\x")) }
    assert_raises { evaluate(%("\\xd")) }
  end

  def test_octal_escape
    assert_equal "\1", evaluate(%("\\1"))
    assert_equal "\2", evaluate(%('\\2'))
    assert_equal "\3", evaluate(%("\\3"))
    assert_equal "\4", evaluate(%('\\4'))
    assert_equal "\5", evaluate(%("\\5"))
    assert_equal "\6", evaluate(%('\\6'))
    assert_equal "\7", evaluate(%("\\7"))

    assert_equal "8", evaluate(%('\\8'))
    assert_equal "\08", evaluate(%("\\08"))
    assert_equal "\09", evaluate(%('\\09'))

    assert_equal [0], evaluate(%("\\00")).codepoints
    assert_equal [8], evaluate(%('\\10')).codepoints
    assert_equal [23], evaluate(%("\\27")).codepoints
    assert_equal [28], evaluate(%('\\34')).codepoints
    assert_equal [228], evaluate(%("\\344")).codepoints
    assert_equal [34], evaluate(%('\\42')).codepoints
    assert_equal [34, 50], evaluate(%("\\422")).codepoints
  end

  def test_arbitrary_escapes
    assert_equal "a", evaluate(%("\\a"))
    assert_equal "\0", evaluate(%("\\0"))
    assert_equal "⌘", evaluate(%('\\⌘'))
    assert_equal "👨‍👩‍👧", evaluate(%('\\👨‍👩‍👧'))
  end

  def test_dangling_escapes
    assert_equal " ", evaluate(%("\ "))
    assert_raises { evaluate(%("\\")) }
  end

  def test_maximum_length
    skip

    # FIXME: Ruby doesn’t seem to handle strings this long
    maximum_length_string = " " *(2 ** 53 -1)

    assert_equal maximum_length_string, evaluate(%("#{maximum_length_string}"))
    assert_raises { evaluate(%("#{maximum_length_string + " "}")) }
  end
end
