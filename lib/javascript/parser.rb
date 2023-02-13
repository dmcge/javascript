require_relative "parser/statement_parser"
require_relative "parser/expression_parser"
require_relative "parser/function_parser"

module Javascript
  class Parser
    def initialize(javascript)
      @tokenizer = Tokenizer.new(javascript)
    end

    def parse
      parse_statement_list until: -> { tokenizer.finished? }
    end

    def parse_statement_list(until:)
      StatementList.new(statements: []).tap do |list|
        list.statements << parse_statement until binding.local_variable_get(:until).call
      end
    end

    def parse_statement
      StatementParser.new(parser: self, tokenizer: tokenizer).parse_statement
    end

    def parse_expression(precedence: 0)
      ExpressionParser.new(parser: self, tokenizer: tokenizer, precedence: precedence).parse_expression
    end

    def parse_expression!(...)
      parse_expression(...) or raise SyntaxError
    end

    private
      attr_reader :tokenizer
  end
end
