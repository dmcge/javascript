module Javascript
  class Parser
    attr_reader :scope

    def initialize(javascript)
      @tokenizer = Tokenizer.new(javascript)
      @scope     = Scope.new
    end

    def parse
      Script.new.tap do |script|
        script.body   = parse_statement_list until: -> { tokenizer.finished? }
        script.scope  = scope
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
      previous_scope = @scope
      @scope = Scope.new
      yield @scope
    ensure
      @scope = previous_scope
    end

    def in_new_lexical_scope
      previous_scope = @scope
      @scope = Scope.new(vars: previous_scope.vars)
      yield @scope
    ensure
      @scope = previous_scope
    end

    private
      attr_reader :tokenizer
  end
end
