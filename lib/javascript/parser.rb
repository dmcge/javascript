require_relative "parser/statement_parser"
require_relative "parser/expression_parser"
require_relative "parser/function_parser"

module Javascript
  class Parser
    attr_reader :variables

    def initialize(javascript)
      @tokenizer = Tokenizer.new(javascript)
      @variables = Set.new
    end

    def parse
      Script.new.tap do |script|
        script.body      = parse_statement_list until: -> { tokenizer.finished? }
        script.variables = variables
      end
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


    def in_new_scope
      previous_variables = @variables
      @variables = Set.new
      yield
    ensure
      @variables = previous_variables
    end

    private
      attr_reader :tokenizer
  end
end
