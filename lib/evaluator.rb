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
      when Number    then evaluate_number(expression)
      when Operation then evaluate_operation(expression)
      end
    end

    def evaluate_number(number)
      number.value
    end

    def evaluate_operation(operation)
      left_hand_side  = BigDecimal(evaluate_expression(operation.left_hand_side))
      right_hand_side = BigDecimal(evaluate_expression(operation.right_hand_side))

      case operation.operator
      when "**" then left_hand_side ** right_hand_side
      when "/"  then left_hand_side / right_hand_side
      when "*"  then left_hand_side * right_hand_side
      when "%"  then left_hand_side % right_hand_side
      when "+"  then left_hand_side + right_hand_side
      when "-"  then left_hand_side - right_hand_side
      when ">"  then left_hand_side > right_hand_side
      when ">=" then left_hand_side >= right_hand_side
      when "<"  then left_hand_side < right_hand_side
      when "<=" then left_hand_side <= right_hand_side
      end
    end
end
