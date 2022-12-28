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
      when Integer             then evaluate_literal(expression)
      when ArithmeticOperation then evaluate_arithmetic_operation(expression)
      end
    end

    def evaluate_literal(literal)
      literal
    end

    def evaluate_arithmetic_operation(operation)
      left_hand_side  = BigDecimal(evaluate_expression(operation.left_hand_side))
      right_hand_side = BigDecimal(evaluate_expression(operation.right_hand_side))

      case operation.operator
      when "/" then left_hand_side / right_hand_side
      when "*" then left_hand_side * right_hand_side
      when "+" then left_hand_side + right_hand_side
      when "-" then left_hand_side - right_hand_side
      end
    end
end
