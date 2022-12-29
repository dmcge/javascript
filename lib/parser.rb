require "bigdecimal"
require_relative "tokenizer"
require_relative "operation"

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
      when tokenizer.consume(Number)              then parse_number
      when tokenizer.consume(Operation::Operator) then parse_operation
      end
    end

    def parse_number
      tokenizer.current_token
    end

    def parse_operation
      operator        = tokenizer.current_token
      left_hand_side  = @expressions.pop
      right_hand_side = parse_expression

      if left_hand_side && right_hand_side
        Operation.new(operator, left_hand_side, right_hand_side)
      else
        raise "Syntax error!"
      end
    end
end
