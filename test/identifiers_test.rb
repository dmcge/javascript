require "test_helper"

class IdentifiersTest < Javascript::Test
  def test_variable_names
    assert_valid "var $"
    assert_valid "let _"
    assert_valid "const ᪧῼ = true"

    assert_valid "const abc123 = true"
    assert_valid "let bengali_six_৫"
    assert_malformed "var 1"
    assert_malformed "let 123456 = 2"
    assert_malformed "var ৫"

    assert_valid "var well\u200d"
    assert_malformed "let \u200dd"

    assert_valid "var fඃd"
    assert_malformed "var ඃ"

    assert_valid "var iffy"
    assert_valid "var elsewhere"
    assert_malformed "var if"
  end
end
