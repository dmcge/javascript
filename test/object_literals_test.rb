require "test_helper"

class ObjectLiteralsTest < Javascript::Test
  def test_single_line
    assert_equal "Joe (23)", evaluate(<<~JS.chomp)
      var person = { name: "Joe", age: 23, active: true }
      person.name + " (" + person.age + ")"
    JS
  end

  def test_multiline
    assert_equal "Shivani is active", evaluate(<<~JS.chomp)
      var person = {
        name: "Shivani",
        age: 22,
        active: true
      }

      if (person.active) {
        person.name + " is active"
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
    assert_equal "Jane", evaluate(<<~JS.chomp)
      var post = {
        title: "Billions lost in hours wasted on implementing features Javascript should have out of the box",
        author: {
          name: "Jane"
        }
      }

      post.author.name
    JS
  end

  def test_string_keys
    assert_equal "Samir", evaluate(<<~JS.chomp)
      var person = { "name": "Samir" }
      person.name
    JS
  end

  def test_numeric_keys
    assert_valid %(var person = { 1: "a" })
  end

  def test_shorthand
    assert_equal "Nora, 32, is from London", evaluate(<<~JS.chomp)
      var name = "Nora", age = 32, location = "London"
      var person = { name, age, location }

      person.name + ", " + person.age + ", is from " + person.location
    JS
  end

  def test_mixing_shorthand_and_longhand
    assert_equal "Colin, 53, is from Mansfield", evaluate(<<~JS.chomp)
      var name = "Colin", location = "Mansfield"
      var person = { name, age: 53, location }

      person.name + ", " + person.age + ", is from " + person.location
    JS
  end
  
  def test_method_definitions
    assert_equal "Hello from method", evaluate(<<~JS)
      var object = {
        toString() {
          return "Hello from method"
        }
      }
      
      object.toString()
    JS
  end
  
  def test_getter_method_definitions
    skip
    assert_equal "Hello from method", evaluate(<<~JS)
      var object = {
        get greeting() {
          return "Hello from method"
        }
      }
      
      object.greeting
    JS
  end
  
  def test_setter_method_definitions
    skip
    assert_equal "Hello", evaluate(<<~JS)
      var object = {}
    
      var mirror = {
        set greeting(value) {
          object.greeting = value
        }
      }
      
      mirror.greeting = "Hello"
      object.greeting
    JS
  end
  
  def test_get_property
    assert_equal "Hello", evaluate(<<~JS)
      var object = { get: "Hello" }
      object.get
    JS
  end
  
  def test_set_property
    assert_equal "Hello", evaluate(<<~JS)
      var object = { set: "Hello" }
      object.set
    JS
  end
  
  def test_spreading_an_object
    skip
    assert_equal({ "a" => 1, "b" => 2, "c" => 3 }, evaluate("var alphabet = { a: 1, ...{ b: 2, c: 3 } }"))
    assert_equal({ "a" => 1 }, evaluate("var alphabet = { a: 1, ...{} }"))
    assert_equal({ "b" => 2 }, evaluate("var alphabet = {...{ b: 2 }}"))
    assert_equal({ "c" => 3, "d" => 4 }, evaluate("var alphabet = {...{ c: 3 }, ...{ d: 4 }}"))
  end
  
  def test_spreading_an_array
    skip
    assert_raises { evaluate("var alphabet = { a: 1, ...[2, 3, 4] }") }
  end

  def test_trailing_commas
    assert_valid   "var alphabet = { a: 1, b: 2, c: 3, }"
    assert_malformed "var alphabet = { a: 1,, }"
    assert_malformed "var alphabet = { , }"
  end

  def test_duplicate_identifiers
    refute evaluate(<<~JS.chomp).true?
      var fail = { ok: true, ok: false }
      fail.ok
    JS
  end

  def test_missing_identifiers
    assert_malformed "var fail = { : 1 }"
    assert_malformed %(var fail = { start: "good", : "but then it goes bad" })
    assert_malformed %(var fail = { start: "good", : "but then it goes bad", then: "it recovers! })
  end

  def test_missing_values
    assert_malformed "var fail = { 1: }"
    assert_malformed %(var fail = { start: "good", then:, yet: "we're back now" })
  end

  def test_missing_colons
    assert_malformed "var fail = { a 1 }"
  end
end
