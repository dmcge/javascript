require_relative "parser"

class Interpreter
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
      when If              then evaluate_if(expression)
      when Branch          then evaluate_branch(expression)
      when UnaryOperation  then evaluate_unary_operation(expression)
      when BinaryOperation then evaluate_binary_operation(expression)
      when Parenthetical   then evaluate_parenthetical(expression)
      end
    end

    def evaluate_string(string)
      string
    end

    def evaluate_number(number)
      number
    end

    def evaluate_if(if_statement)
      if evaluate_expression(if_statement.condition).true?
        evaluate_expression(if_statement.consequent)
      elsif if_statement.alternative
        evaluate_expression(if_statement.alternative)
      end
    end

    def evaluate_branch(branch)
      result = evaluate_expression(branch.expressions.shift) until branch.expressions.empty?
      result
    end

    def evaluate_unary_operation(operation)
      operation.operator.perform_unary(evaluate_expression(operation.operand))
    end

    def evaluate_binary_operation(operation)
      left_hand_side  = evaluate_expression(operation.left_hand_side)
      right_hand_side = evaluate_expression(operation.right_hand_side)

      operation.operator.perform_binary(left_hand_side, right_hand_side)
    end

    def evaluate_parenthetical(parenthetical)
      evaluate_expression(parenthetical.expression)
    end
end
