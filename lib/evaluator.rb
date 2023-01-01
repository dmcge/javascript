require_relative "parser"

class Evaluator
  def initialize(script)
    @expressions = Parser.new(script).parse
  end

  def evaluate
    result = nil
    @expressions.each { |expression| result = evaluate_expression(expression) }
    result
  end

  private
    def evaluate_expression(expression)
      case expression
      when String          then evaluate_string(expression)
      when Number          then evaluate_number(expression)
      when UnaryOperation  then evaluate_unary_operation(expression)
      when BinaryOperation then evaluate_binary_operation(expression)
      end
    end

    def evaluate_string(string)
      string
    end

    def evaluate_number(number)
      number
    end

    def evaluate_unary_operation(operation)
      value = evaluate_expression(operation.operand)

      case operation.operator.value
      when "+" then value.to_number
      when "-" then -value.to_number
      end
    end

    def evaluate_binary_operation(operation)
      left_hand_side  = evaluate_expression(operation.left_hand_side)
      right_hand_side = evaluate_expression(operation.right_hand_side)

      case operation.operator.value
      when "**" then left_hand_side.to_number ** right_hand_side.to_number
      when "/"  then left_hand_side.to_number /  right_hand_side.to_number
      when "*"  then left_hand_side.to_number *  right_hand_side.to_number
      when "%"  then left_hand_side.to_number %  right_hand_side.to_number
      when "+"
        if left_hand_side.is_a?(String) || right_hand_side.is_a?(String)
          left_hand_side  = left_hand_side.to_s
          right_hand_side = right_hand_side.to_s
        end

        left_hand_side + right_hand_side
      when "-"   then left_hand_side.to_number - right_hand_side.to_number
      when ">"   then left_hand_side > right_hand_side
      when ">="  then left_hand_side >= right_hand_side
      when "<"   then left_hand_side < right_hand_side
      when "<="  then left_hand_side <= right_hand_side
      when "-"   then left_hand_side.to_number - right_hand_side.to_number
      when "<<"  then left_hand_side.to_number << right_hand_side.to_number
      when ">>"  then left_hand_side.to_number >> right_hand_side.to_number
      when ">>>" then left_hand_side.to_number.unsigned >> right_hand_side.to_number
      end
    end
end
