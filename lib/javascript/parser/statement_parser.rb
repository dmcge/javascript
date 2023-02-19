module Javascript
  class Parser
    class StatementParser
      def initialize(parser:, tokenizer:)
        @parser, @tokenizer = parser, tokenizer
      end

      def parse_statement
        case
        when tokenizer.consume(:var)      then parse_var_statement
        when tokenizer.consume("let")     then parse_let_statement_or_expression
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

        def parse_var_statement
          parse_variable_declarations(VarStatement.new(declarations: [])) do |declaration|
            parser.vars << declaration.name
          end
        end

        def parse_let_statement_or_expression
          if tokenizer.peek(:identifier)
            parse_let_statement
          else
            tokenizer.rewind
            parse_expression_statement
          end
        end

        def parse_let_statement
          parse_variable_declarations(LetStatement.new(declarations: [])) do |declaration|
            case
            when declaration.name == "let"
              raise SyntaxError
            when parser.lets.include?(declaration.name)
              raise SyntaxError
            else
              parser.lets << declaration.name
            end
          end
        end

        def parse_variable_declarations(statement)
          tokenizer.until(:semicolon) do
            declaration = parse_variable_declaration
            yield declaration
            statement.declarations << declaration

            break unless tokenizer.consume(:comma)
          end

          statement
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
          parser.in_new_lexical_scope do
            Block.new.tap do |block|
              block.body = parser.parse_statement_list(until: -> { tokenizer.consume("}") })
              block.lets = parser.lets
            end
          end
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
