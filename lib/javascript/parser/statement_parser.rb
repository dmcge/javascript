module Javascript
  class Parser
    class StatementParser
      def initialize(parser:, tokenizer:)
        @parser, @tokenizer = parser, tokenizer
      end

      def parse_statement
        case
        when tokenizer.consume(:var)      then parse_variable_statement
        when tokenizer.consume(:if)       then parse_if_statement
        when tokenizer.consume(:function) then parse_function_declaration
        when tokenizer.consume("{")       then parse_block
        when tokenizer.consume(:return)   then parse_return_statement
        when tokenizer.consume(";")       then parse_empty_statement
        else
          parse_expression_statement
        end
      end

      private
        attr_reader :parser, :tokenizer

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
            declaration.value = parser.parse_expression!(precedence: 2) if tokenizer.consume(:equals)
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
            parser.parse_expression!.tap do
              raise SyntaxError unless tokenizer.consume(")")
            end
          else
            raise SyntaxError
          end
        end

        def parse_function_declaration
          if tokenizer.peek(:identifier)
            FunctionDeclaration.new(parse_function)
          else
            tokenizer.rewind
            parser.parse_expression
          end
        end

        def parse_function
          FunctionParser.new(parser: parser, tokenizer: tokenizer).parse_function
        end

        def parse_block
          Block.new(parser.parse_statement_list(until: -> { tokenizer.consume("}") }))
        end

        def parse_return_statement
          Return.new(parser.parse_expression)
        end

        def parse_empty_statement
          parse_statement unless tokenizer.finished?
        end

        def parse_expression_statement
          ExpressionStatement.new(parser.parse_expression).tap do
            raise SyntaxError.new("Unexpected #{tokenizer.next_token.value}") unless tokenizer.consume(:semicolon) || tokenizer.consume(:end_of_file) || tokenizer.consume(:line_break)
          end
        end
    end
  end
end
