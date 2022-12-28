require "bigdecimal"
require_relative "tokenizer"
require_relative "arithmetic_operation"

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
