require_relative "tokenizer"
require_relative "binary_operation"
require_relative "unary_operation"

Parenthetical = Struct.new(:expression)

class Parser
  def initialize(javascript)
    @tokenizer = Tokenizer.new(javascript)
    @expressions = []
  end

  def parse
    [].tap do |expressions|
      expressions.concat(parse_statement) until tokenizer.finished?
    end
  end

  private
    attr_reader :tokenizer

    def parse_statement
      @expressions = []

      until tokenizer.finished? || tokenizer.consume(:semicolon)
        expression = parse_expression
        @expressions << expression
      end

      @expressions
    end

    def parse_expression
      case
      when tokenizer.consume(:string)          then parse_string
      when tokenizer.consume(:number)          then parse_number
      when tokenizer.consume(:operator)        then parse_operation
      when tokenizer.consume(:opening_bracket) then parse_parenthetical
      else
        raise "Can’t parse #{tokenizer.next_token.inspect}"
      end
    end

    def parse_string
      Javascript::String.new(tokenizer.current_token.literal)
    end

    def parse_number
      if @expressions.empty? || @expressions.last.is_a?(Operation)
        Number.new(tokenizer.current_token.literal)
      else
        raise "Syntax error!"
      end
    end

    def parse_operation
      if @expressions.none?
        parse_unary_operation
      else
        parse_binary_operation
      end
    end

    def parse_unary_operation
      operator = Operator.for(tokenizer.current_token.text)

      if operator.unary? && operand = parse_expression
        UnaryOperation.new(operator, operand)
      else
        raise "Syntax error!"
      end
    end

    def parse_binary_operation
      operator        = Operator.for(tokenizer.current_token.text)
      left_hand_side  = @expressions.pop
      right_hand_side = parse_expression

      if left_hand_side && right_hand_side
        BinaryOperation.new(operator, left_hand_side, right_hand_side)
      else
        raise "Syntax error!"
      end
    end

    def parse_parenthetical
      previous_expressions = @expressions.dup

      Parenthetical.new.tap do |parenthetical|
        loop do
          case
          when tokenizer.consume(:semicolon)
            raise "Semicolon!"
          when tokenizer.consume(:closing_bracket)
            break
          else
            @expressions << parse_expression
          end
        end

        expressions = @expressions - previous_expressions
        @expressions = previous_expressions

        if expressions.one?
          parenthetical.expression = expressions.first
        else
          raise "Syntax error!"
        end
      end
    end
end
