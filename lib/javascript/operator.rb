module Javascript
  class Operator
    def self.for(symbol)
      case symbol
      when "++"  then Increment
      when "--"  then Decrement
      when "**"  then Exponentiation
      when "/"   then Division
      when "*"   then Multiplication
      when "%"   then Modulo
      when "+"   then Plus
      when "-"   then Minus
      when ">"   then GreaterThan
      when ">="  then GreaterThanOrEqual
      when "<"   then LessThan
      when "<="  then LessThanOrEqual
      when "<<"  then ShiftLeft
      when ">>"  then ShiftRight
      when ">>>" then ShiftRightUnsigned
      when "=="  then Equality
      when "!="  then Inequality
      when "===" then StrictEquality
      when "!==" then StrictInequality
      when "!"   then Not
      when "&"   then BitwiseAnd
      when "^"   then BitwiseXor
      when "|"   then BitwiseOr
      when "&&"  then And
      when "||"  then Or
      when ","   then Comma
      end.new
    end

    def perform_binary(left_hand_side, right_hand_side)
      raise NotImplementedError
    end

    def perform_unary(operand)
      raise NotImplementedError
    end

    def binary?
      method(:perform_binary).unbind != Operator.instance_method(:perform_binary)
    end

    def unary?
      method(:perform_unary).unbind != Operator.instance_method(:perform_unary)
    end

    def right_associative?
      false
    end


    class Increment < Operator
      def perform_unary(operand, position:)
        old_value = operand.value
        new_value = operand.value = update_value(operand.value)

        case position
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
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number ** right_hand_side.to_number
      end

      def right_associative?
        true
      end
    end

    class Division < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number / right_hand_side.to_number
      end
    end

    class Multiplication < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number * right_hand_side.to_number
      end
    end

    class Modulo < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number % right_hand_side.to_number
      end
    end

    class Plus < Operator
      def perform_binary(left_hand_side, right_hand_side)
        if left_hand_side.is_a?(String) || right_hand_side.is_a?(String)
          left_hand_side.to_string + right_hand_side.to_string
        else
          left_hand_side.to_number + right_hand_side.to_number
        end
      end

      def perform_unary(operand)
        operand.to_number
      end
    end

    class Minus < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number - right_hand_side.to_number
      end

      def perform_unary(operand)
        -operand.to_number
      end
    end

    class Comparison < Operator
      def perform_binary(left_hand_side, right_hand_side)
        if left_hand_side.is_a?(String) && right_hand_side.is_a?(String)
          Boolean.wrap(compare(left_hand_side, right_hand_side))
        else
          Boolean.wrap(compare(left_hand_side.to_number, right_hand_side.to_number))
        end
      end

      private
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
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number << right_hand_side.to_number
      end
    end

    class ShiftRight < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number >> right_hand_side.to_number
      end
    end

    class ShiftRightUnsigned < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number.unsigned >> right_hand_side.to_number
      end
    end

    class Equality < Operator
      def perform_binary(left_hand_side, right_hand_side)
        Boolean.wrap(equivalent?(left_hand_side, right_hand_side))
      end

      private
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
      def perform_unary(operand)
        !operand.to_boolean
      end
    end

    class BitwiseAnd < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number & right_hand_side.to_number
      end
    end

    class BitwiseXor < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number ^ right_hand_side.to_number
      end
    end

    class BitwiseOr < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number | right_hand_side.to_number
      end
    end

    # FIXME
    class And < Operator
      def perform_binary(left_hand_side, right_hand_side)
      end
    end

    # FIXME
    class Or < Operator
      def perform_binary(left_hand_side, right_hand_side)
      end
    end

    class Comma < Operator
      def perform_binary(left_hand_side, right_hand_side)
        right_hand_side
      end
    end
  end
end
