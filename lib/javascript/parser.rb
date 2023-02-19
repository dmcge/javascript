require_relative "parser/statement_parser"
require_relative "parser/expression_parser"
require_relative "parser/function_parser"

module Javascript
  class Parser
    attr_reader :vars, :lets

    def initialize(javascript)
      @tokenizer = Tokenizer.new(javascript)
      @vars      = Set.new
      @lets      = Set.new
    end

    def parse
      Script.new.tap do |script|
        script.body = parse_statement_list until: -> { tokenizer.finished? }
        script.vars = vars
        script.lets = lets
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
      previous_vars, previous_lets = @vars, @lets
      @vars, @lets = Set.new, Set.new
      yield
    ensure
      @vars, @lets = previous_vars, previous_lets
    end

    def in_new_lexical_scope
      previous_lets = @lets
      @lets = Set.new
      yield
    ensure
      @lets = previous_lets
    end

    private
      attr_reader :tokenizer
  end
end
