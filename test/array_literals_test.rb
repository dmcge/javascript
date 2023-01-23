require "test_helper"

class ArrayLiteralsTest < Javascript::Test
  def test_single_line
    assert_equal ["a", "b", "c"], evaluate(%(["a", "b", "c"]))
    assert_equal [1, 2, 4], evaluate("[2 ** 0, 2 ** 1, 2 ** 2]")
  end

  def test_empty
    assert_equal [], evaluate("[]")
    assert_equal [], evaluate("[ ]")
    assert_equal [], evaluate("[\n]")
  end

  def test_trailing_commas
    assert_equal [1], evaluate("[1, ]")
    assert_equal [1, 2], evaluate("[1, 2,]")
  end

  def test_empty_elements
    assert_equal [1, nil, 2], evaluate("[1,,2]")
    assert_equal [1, nil, 2], evaluate(<<~JS.chomp)
      [
        1,
        ,
        2
      ]
    JS
  end

  def test_nothing_but_commas
    assert_equal [nil], evaluate("[,]")
    assert_equal [nil, nil, nil], evaluate("[,,,]")
  end

  def test_unclosed_array
    assert_invalid "[1, 2"
    assert_invalid "[1, 2, 3,"
  end
end
