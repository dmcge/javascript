module Javascript
  class Operator
    def self.for(symbol, interpreter:)
      case symbol
      when "++"     then Increment
      when "--"     then Decrement
      when "**"     then Exponentiation
      when "/"      then Division
      when "*"      then Multiplication
      when "%"      then Modulo
      when "+"      then Plus
      when "-"      then Minus
      when ">"      then GreaterThan
      when ">="     then GreaterThanOrEqual
      when "<"      then LessThan
      when "<="     then LessThanOrEqual
      when "<<"     then ShiftLeft
      when ">>"     then ShiftRight
      when ">>>"    then ShiftRightUnsigned
      when "=="     then Equality
      when "!="     then Inequality
      when "==="    then StrictEquality
      when "!=="    then StrictInequality
      when "!"      then Not
      when "~"      then BitwiseNot
      when "&"      then BitwiseAnd
      when "^"      then BitwiseXor
      when "|"      then BitwiseOr
      when "&&"     then And
      when "||"     then Or
      when ","      then Comma
      when "typeof" then TypeOf
      when "void"   then Void
      end.new(interpreter)
    end

    def initialize(interpreter)
      @interpreter = interpreter
    end

    def binary(operation)
      left_hand_side  = interpreter.evaluate_value(operation.left_hand_side)
      right_hand_side = interpreter.evaluate_value(operation.right_hand_side)

      perform_binary(left_hand_side, right_hand_side)
    end

    def unary(operation)
      perform_unary(interpreter.evaluate_value(operation.operand), position: operation.position)
    end

    private
      attr_reader :interpreter

      def perform_binary(left_hand_side, right_hand_side)
        raise NotImplementedError
      end

      def perform_unary(operand, position:)
        raise NotImplementedError
      end


    class Increment < Operator
      def unary(operation)
        operand   = interpreter.evaluate_expression(operation.operand)
        old_value = operand.value
        new_value = operand.value = update_value(operand.value)

        case operation.position
        when :prefix  then new_value
        when :postfix then old_value
        end
      end

      private
        def update_value(value)
          value.to_number + Number.new(1)
        end
    end

    class Decrement < Increment
      private

      def update_value(value)
        value.to_number - Number.new(1)
      end
    end

    class Exponentiation < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number ** right_hand_side.to_number
      end
    end

    class Division < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number / right_hand_side.to_number
      end
    end

    class Multiplication < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number * right_hand_side.to_number
      end
    end

    class Modulo < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number % right_hand_side.to_number
      end
    end

    class Plus < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        if left_hand_side.is_a?(String) || right_hand_side.is_a?(String)
          left_hand_side.to_string + right_hand_side.to_string
        else
          left_hand_side.to_number + right_hand_side.to_number
        end
      end

      def perform_unary(operand, position:)
        operand.to_number
      end
    end

    class Minus < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number - right_hand_side.to_number
      end

      def perform_unary(operand, position:)
        -operand.to_number
      end
    end

    class Comparison < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        if left_hand_side.is_a?(String) && right_hand_side.is_a?(String)
          Boolean.wrap(compare(left_hand_side, right_hand_side))
        else
          Boolean.wrap(compare(left_hand_side.to_number, right_hand_side.to_number))
        end
      end

      def compare(left_hand_side, right_hand_side)
        raise NotImplementedError
      end
    end

    class GreaterThan < Comparison
      private

      def compare(left_hand_side, right_hand_side)
        left_hand_side > right_hand_side
      end
    end

    class GreaterThanOrEqual < Comparison
      private

      def compare(left_hand_side, right_hand_side)
        left_hand_side >= right_hand_side
      end
    end

    class LessThan < Comparison
      private

      def compare(left_hand_side, right_hand_side)
        left_hand_side < right_hand_side
      end
    end

    class LessThanOrEqual < Comparison
      private

      def compare(left_hand_side, right_hand_side)
        left_hand_side <= right_hand_side
      end
    end

    class ShiftLeft < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number << right_hand_side.to_number
      end
    end

    class ShiftRight < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number >> right_hand_side.to_number
      end
    end

    class ShiftRightUnsigned < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number.unsigned >> right_hand_side.to_number
      end
    end

    class Equality < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        Boolean.wrap(equivalent?(left_hand_side, right_hand_side))
      end

      def equivalent?(left_hand_side, right_hand_side)
        case
        when left_hand_side.class == right_hand_side.class
          left_hand_side == right_hand_side
        when left_hand_side.is_a?(Number) && right_hand_side.is_a?(String)
          left_hand_side == right_hand_side.to_number
        when left_hand_side.is_a?(String) && right_hand_side.is_a?(Number)
          left_hand_side.to_number == right_hand_side
        when left_hand_side.is_a?(Boolean)
          left_hand_side.to_number == right_hand_side
        when right_hand_side.is_a?(Boolean)
          left_hand_side == right_hand_side.to_number
        else
          false
        end
      end
    end

    class Inequality < Equality
      private

      def equivalent?(left_hand_side, right_hand_side)
        !super
      end
    end

    class StrictEquality < Equality
      private

      def equivalent?(left_hand_side, right_hand_side)
        left_hand_side.class == right_hand_side.class && left_hand_side == right_hand_side
      end
    end

    class StrictInequality < StrictEquality
      private

      def equivalent?(left_hand_side, right_hand_side)
        !super
      end
    end

    class Not < Operator
      private

      def perform_unary(operand, position:)
        !operand.to_boolean
      end
    end

    class BitwiseNot < Operator
      private

      def perform_unary(operand, position:)
        ~operand.to_number
      end
    end

    class BitwiseAnd < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number & right_hand_side.to_number
      end
    end

    class BitwiseXor < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number ^ right_hand_side.to_number
      end
    end

    class BitwiseOr < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number | right_hand_side.to_number
      end
    end

    class And < Operator
      def binary(operation)
        if (left_hand_side = interpreter.evaluate_value(operation.left_hand_side)).truthy?
          interpreter.evaluate_value(operation.right_hand_side)
        else
          left_hand_side
        end
      end
    end

    class Or < Operator
      def binary(operation)
        if (left_hand_side = interpreter.evaluate_value(operation.left_hand_side)).truthy?
          left_hand_side
        else
          interpreter.evaluate_value(operation.right_hand_side)
        end
      end
    end

    class Comma < Operator
      private

      def perform_binary(left_hand_side, right_hand_side)
        right_hand_side
      end
    end

    class TypeOf < Operator
      def unary(operation)
        String.new(extract_type(operation.operand))
      end

      private
        def extract_type(operand)
          result = interpreter.evaluate_expression(operand)

          case result
          when Interpreter::Environment::Binding, Object::Property
            result.value.type
          when Interpreter::UnresolvedReference
            "undefined"
          else
            result.type
          end
        end
    end

    class Void < Operator
      private

      def perform_unary(operand, position:)
        nil
      end
    end
  end
end
