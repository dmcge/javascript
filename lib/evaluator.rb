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
      left_hand_side  = evaluate_expression(operation.left_hand_side)
      right_hand_side = evaluate_expression(operation.right_hand_side)

      case operation.operator.value
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
      when "<<" then left_hand_side.to_i << (right_hand_side.to_i % 32)
      when ">>" then left_hand_side.to_i >> (right_hand_side.to_i % 32)
      when ">>>"
        unsigned_value = ("%.32b" % left_hand_side.to_i).sub(/^\.\./, "11").to_i(2)
        unsigned_value >> right_hand_side.to_i % 32
      end
    end
end
