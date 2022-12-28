require "bigdecimal"
require_relative "tokenizer"

class ArithmeticOperation
  attr_reader :operator, :left_hand_side, :right_hand_side

  def initialize(operator, left_hand_side, right_hand_side)
    if left_hand_side.is_a?(ArithmeticOperation) && precedence_of(operator) > precedence_of(left_hand_side.operator)
      @operator        = left_hand_side.operator
      @left_hand_side  = left_hand_side.left_hand_side
      @right_hand_side = ArithmeticOperation.new(operator, left_hand_side.right_hand_side, right_hand_side)
    else
      @operator        = operator
      @left_hand_side  = left_hand_side
      @right_hand_side = right_hand_side
    end
  end

  private
    OPERATOR_PRECEDENCE = { "/" => 2, "*" => 2, "+" => 1, "-" => 1 }

    def precedence_of(operator)
      OPERATOR_PRECEDENCE[operator]
    end
end

class Parser
  def initialize(javascript)
    @tokenizer = Tokenizer.new(javascript)
    @expressions = []
  end

  def parse
    @expressions << parse_expression until tokenizer.finished?
    @expressions
  end

  private
    attr_reader :tokenizer

    def parse_expression
      case
      when tokenizer.consume(Number)  then parse_number
      when tokenizer.consume("+")     then parse_arithemetic_operation
      when tokenizer.consume("-")     then parse_arithemetic_operation
      when tokenizer.consume("*")     then parse_arithemetic_operation
      when tokenizer.consume("/")     then parse_arithemetic_operation
      end
    end

    def parse_number
      tokenizer.current_token
    end

    def parse_arithemetic_operation
      operator        = tokenizer.current_token
      left_hand_side  = @expressions.pop
      right_hand_side = parse_expression

      ArithmeticOperation.new(operator, left_hand_side, right_hand_side)
    end
end
