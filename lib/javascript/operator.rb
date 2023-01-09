module Javascript
  class Operator
    ALL = {
      "**"  => { class: "Exponentiation",     precedence: 5              },
      "/"   => { class: "Division",           precedence: 4              },
      "*"   => { class: "Multiplication",     precedence: 4              },
      "%"   => { class: "Modulo",             precedence: 4              },
      "+"   => { class: "Plus",               precedence: 3, unary: true },
      "-"   => { class: "Minus",              precedence: 3, unary: true },
      ">"   => { class: "GreaterThan",        precedence: 2              },
      ">="  => { class: "GreaterThanOrEqual", precedence: 2              },
      "<"   => { class: "LessThan",           precedence: 2              },
      "<="  => { class: "LessThanOrEqual",    precedence: 2              },
      "<<"  => { class: "ShiftLeft",          precedence: 1              },
      ">>"  => { class: "ShiftRight",         precedence: 1              },
      ">>>" => { class: "ShiftRightUnsigned", precedence: 1              },
      "=="  => { class: "Equality",           precedence: 0              },
      "!="  => { class: "Inequality",         precedence: 0              }
    }

    SYMBOLS = ALL.keys

    attr_reader :precedence, :unary
    alias unary? unary

    def initialize(precedence:, unary: false)
      @precedence, @unary = precedence, unary
    end

    def self.for(symbol)
      const_get(ALL[symbol][:class].to_sym).new(**ALL[symbol].slice(:precedence, :unary))
    end

    def perform_binary(left_hand_side, right_hand_side)
      raise NotImplementedError
    end

    def perform_unary(operand)
      raise NotImplementedError
    end


    class Exponentiation < Operator
      def perform_binary(left_hand_side, right_hand_side)
        left_hand_side.to_number ** right_hand_side.to_number
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
          left_hand_side.to_s + right_hand_side.to_s
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
  end
end