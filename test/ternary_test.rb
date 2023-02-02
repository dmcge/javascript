require "test_helper"

class TernaryTest < Javascript::Test
  def test_single_line
    assert_equal 1, evaluate("true ? 1 : 0")
    assert_equal 2, evaluate("0 ? 1 : 2")
  end

  def test_multiline
    assert_equal "yes, that's true", evaluate(<<~JS.chomp)
      (3.5 > 2 ** 1.5)
        ?
          "yes, that's true"
        :
          "no, sorry"
    JS
  end

  def test_nested
    assert_equal "yes yes", evaluate(%(true ? true ? "yes yes" : "yes no" : "no no"))
    assert_equal "yes no", evaluate(%(true ? false ? "yes yes" : "yes no" : "no no"))
    assert_equal "no no", evaluate(%(false ? false ? "yes yes" : "yes no" : "no no"))
  end

  def test_missing_colon
    assert_malformed %("well?" ? "then")
    assert_malformed %("well?" ? "then" ? "yes" : "no")
  end
end
