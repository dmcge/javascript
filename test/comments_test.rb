require "test_helper"

class CommentsTest < Javascript::Test
  def test_single_line_comments
    assert_equal 2, evaluate("1 // Magic number!\n2")
    assert_equal 3, evaluate("1 // Magic number!; 2\n3")
    assert_equal 2, evaluate("1 //Look, no spaces!\n2")
    assert_equal 1, evaluate("1 // End of the file!")
    assert_equal 1, evaluate("1 // If it weren’t for those meddling trailing new lines!\n")
  end

  def test_multiline_comments
    assert_equal 2, evaluate("/* Magic number!*/\n2")
    assert_equal 2, evaluate("1 /* Magic number!*/\n2")
    assert_equal 2, evaluate("1 /* Magic number!\n*/2")
    assert_equal 1, evaluate(<<~JAVASCRIPT.chomp)
      1 /*


      All the way down here!

      */
    JAVASCRIPT
  end

  def test_unterminated_multiline_comment
    assert_malformed "/*"
    assert_malformed "/*\n\n\nYo"
  end

  def test_only_comments
    assert_nil evaluate("// Well then")
    assert_nil evaluate("/* This is awkward */")
    assert_nil evaluate(<<~JAVASCRIPT.chomp)
      /*
        All these lines.
        And for what?
      */
    JAVASCRIPT
  end
end
