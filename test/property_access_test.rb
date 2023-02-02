require "test_helper"

class PropertyAccessTest < Javascript::Test
  def test_accessing_object_with_dot
    assert_equal "Kate", evaluate(<<~JS.chomp)
      var person = { name: "Kate", age: 38, active: true }
      person.name
    JS
  end

  def test_accessing_object_by_string
    assert_equal "Joe", evaluate(<<~JS.chomp)
      var person = { name: "Joe", age: 23, active: true }
      person["name"]
    JS
  end

  def test_accessing_object_by_reference
    assert_equal 22, evaluate(<<~JS.chomp)
      var person   = { name: "Shivani", age: 22, active: true }
      var property = "age"
      person[property]
    JS
  end

  def test_accessing_array_by_index
    assert_equal 1, evaluate("[0, 1, 2, 3][1]")
    assert_equal "b", evaluate(%([["a", "b", "c"]][0][1]))
  end

  def test_accessing_array_by_expression
    assert_equal 6, evaluate("[4, 5, 6][2 - 1 * 0]")
  end

  def test_accessing_array_with_dot
    assert_malformed "[0, 1].0"
    assert_malformed "[0, 1]..0"
  end

  def test_accessing_accessing_nonexistent_property
    assert_equal [nil, nil, nil], evaluate(<<~JS.chomp)
      var object = {};
      var key = "a";
      [ object.a, object["a"], object[key] ]
    JS
  end
end
