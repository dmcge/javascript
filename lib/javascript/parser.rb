require_relative "parser/expression_parser"

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
      case
      when tokenizer.consume(:var)    then parse_variable_statement
      when tokenizer.consume(:if)     then parse_if_statement
      when tokenizer.consume("{")     then parse_block
      when tokenizer.consume(:return) then parse_return_statement
      when tokenizer.consume(";")     then parse_empty_statement
      else
        parse_expression_statement
      end
    end

    def parse_block
      Block.new(parse_statement_list(until: -> { tokenizer.consume("}") }))
    end

    def parse_expression(precedence: 0)
      ExpressionParser.new(parser: self, tokenizer: tokenizer, precedence: precedence).parse_expression
    end

    def parse_expression!(...)
      parse_expression(...) or raise SyntaxError
    end

    private
      attr_reader :tokenizer

      def parse_variable_statement
        VariableStatement.new(declarations: []).tap do |statement|
          tokenizer.until(:semicolon) do
            statement.declarations << parse_variable_declaration

            break unless tokenizer.consume(:comma)
          end
        end
      end

      def parse_variable_declaration
        VariableDeclaration.new.tap do |declaration|
          declaration.name  = tokenizer.consume!(:identifier).value
          declaration.value = parse_expression!(precedence: 2) if tokenizer.consume(:equals)
        end
      end

      def parse_if_statement
        If.new \
          condition:   parse_condition,
          consequent:  parse_statement,
          alternative: (parse_statement if tokenizer.consume(:else))
      end

      def parse_condition
        if tokenizer.consume("(")
          parse_expression!.tap do
            raise SyntaxError unless tokenizer.consume(")")
          end
        else
          raise SyntaxError
        end
      end

      def parse_return_statement
        Return.new(parse_expression)
      end

      def parse_empty_statement
        parse_statement unless tokenizer.finished?
      end

      def parse_expression_statement
        ExpressionStatement.new(parse_expression).tap do
          raise SyntaxError.new("Unexpected #{tokenizer.next_token.value}") unless tokenizer.consume(:semicolon) || tokenizer.consume(:end_of_file) || tokenizer.consume(:line_break)
        end
      end
  end
end
