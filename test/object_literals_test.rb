require "test_helper"

class ObjectLiteralsTest < Javascript::Test
  def test_single_line
    assert_valid %(var person = { name: "Joe", age: 23, active: true })
  end

  def test_multiline
    assert_valid <<~JS.chomp
      var person = {
        name: "Shivani",
        age: 22,
        active: true
      }
    JS
  end

  def test_empty
    assert_valid %(var person = {})
    assert_valid <<~JS.chomp
      var person = {
      }
    JS
  end

  def test_nesting
    assert_valid <<~JS.chomp
      var post = {
        title: "Billions lost in hours wasted on implementing features Javascript should have out of the box",
        author: {
          name: "Jane"
        }
      }
    JS
  end

  def test_string_keys
    assert_valid %(var person = { "name": "Samir" })
  end

  def test_numeric_keys
    assert_valid %(var person = { 1: "a" })
  end

  def test_shorthand
    assert_valid "var person = { name, age, location }"
  end

  def test_trailing_commas
    assert_valid   "var alphabet = { a: 1, b: 2, c: 3, }"
    assert_invalid "var alphabet = { a: 1,, }"
    assert_invalid "var alphabet = { , }"
  end

  def test_duplicate_identifiers
    assert_valid %(var fail = { ok: true, ok: false })
  end

  def test_missing_identifiers
    assert_invalid "var fail = { : 1 }"
    assert_invalid %(var fail = { start: "good", : "but then it goes bad" })
    assert_invalid %(var fail = { start: "good", : "but then it goes bad", then: "it recovers! })
  end

  def test_missing_values
    assert_invalid "var fail = { 1: }"
    assert_invalid %(var fail = { start: "good", then:, yet: "we're back now" })
  end
end
