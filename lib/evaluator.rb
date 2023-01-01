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
      operation.operator.perform_unary(evaluate_expression(operation.operand))
    end

    def evaluate_binary_operation(operation)
      left_hand_side  = evaluate_expression(operation.left_hand_side)
      right_hand_side = evaluate_expression(operation.right_hand_side)

      operation.operator.perform_binary(left_hand_side, right_hand_side)
    end
end
