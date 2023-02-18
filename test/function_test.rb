require "test_helper"

class FunctionTest < Javascript::Test
  def test_function_calls
    assert_equal 5, evaluate(<<~JS)
      function add(a, b) {
        return a + b
      }

      add(2, 3)
    JS
  end

  def test_anonymous_functions
    assert_equal 20, evaluate(<<~JS)
      var multiply = function(a, b) {
        return a * b
      }

      multiply(4, 5)
    JS
  end

  def test_referencing_functions_by_name
    assert_equal 4, evaluate(<<~JS)
      function double(n) {
        return n * 2
      }

      function call_indirect(func, argument) {
        return func(argument)
      }

      call_indirect(double, 2)
    JS
  end


  def test_default_values
    assert 4, evaluate(<<~JS)
      function double(n = 2) {
        return n * 2
      }

      double()
    JS

    assert 2, evaluate(<<~JS)
      function add(a, b = 1) {
        return a + b
      }

      add(1)
    JS
  end

  def test_overriding_default_values
    assert 3, evaluate(<<~JS)
      function add(a, b = 1) {
        return a + b
      }

      add(1, 2)
    JS
  end

  def test_default_value_referring_to_a_previous_argument
    assert 8, evaluate(<<~JS)
      function add(a, b = a) {
        return a + b
      }

      add(4)
    JS
  end

  def test_default_value_referring_to_a_subsequent_argument
    assert_raises do
      evaluate(<<~JS)
        function add(a = b, b) {
          return a + b
        }

        add(null, 4)
      JS
    end
  end

  def test_default_value_referring_to_itself
    assert_raises do
      evaluate(<<~JS)
        function pathological(a = a) {
          return a
        }

        pathological()
      JS
    end
  end

  def test_unspecified_default_value
    assert_malformed(<<~JS)
      function add(a, b =) {
        return a + b
      }
    JS
  end


  def test_no_return
    assert_nil evaluate(<<~JS)
      function double(n) {
        n * 2
      }

      double(2)
    JS
  end

  def test_early_return
    assert_equal "tricked ya!", evaluate(<<~JS)
      function double(n) {
        return "tricked ya!"
        return n * 2
      }

      double(2)
    JS
  end

  def test_void_return
    assert_nil evaluate(<<~JS)
      function no_op() {
        return
      }

      no_op()
    JS
  end

  def test_currying
    assert_equal 11, evaluate(<<~JS)
      function curry_add(a) {
        return function(b) {
          return a + b
        }
      }

      curry_add(5)(6)
    JS
  end

  def test_variables_are_confined_to_the_function
    assert_raises do
      evaluate <<~JS
        function leaky() {
          var leak
        }

        leaky()
        leak
      JS
    end
  end

  def test_variables_are_unique_to_each_function_call
    assert_nil evaluate(<<~JS)
      function leaky(define) {
        if (define) {
          var leak = "a"
        } else {
          return leak
        }
      }

      leaky(true)
      leaky(false)
    JS
  end

  def test_updating_global_variables
    assert_equal "hijacked!", evaluate(<<~JS)
      var value

      function hijack() {
        value = "hijacked!"
      }

      hijack()
      value
    JS
  end

  def test_shadowing_outer_variables
    assert_equal ["ssshh", "don't change me"], evaluate(<<~JS)
      var value = "don't change me"

      function shadow() {
        var value = "ssshh"
        return value
      }

      [ shadow(), value ]
    JS
  end

  def test_shadowing_outer_variables_with_a_parameter
    assert_equal ["ssshh", "don't change me"], evaluate(<<~JS)
      var value = "don't change me"

      function shadow(value) {
        return value
      }

      [ shadow("ssshh"), value ]
    JS
  end

  def test_variables_are_scoped_to_an_entire_function
    assert_equal "it works!", evaluate(<<~JS)
      function test(value) {
        if (true) {
          var value = "it works!"
        }

        return value
      }

      test()
    JS
  end


  def test_recursive_functions
    assert_equal 6, evaluate(<<~JS)
      function factorial (n) {
        if (n == 0) {
          return 1
        } else {
          return n * factorial(n - 1)
        }
      }

      factorial(3)
    JS
  end

  def test_calling_named_function_expressions
    assert_equal 6, evaluate(<<~JS)
      (function factorial (n) {
        if (n == 0) {
          return 1
        } else {
          return n * factorial(n - 1)
        }
      })(3)
    JS
  end

  def test_calling_named_function_expressions_from_outside_the_function
    assert_raises do
      evaluate(<<~JS)
        (function factorial (n) {
          if (n == 0) {
            return 1
          } else {
            return n * factorial(n - 1)
          }
        })

        factorial(3)
      JS
    end
  end
end
