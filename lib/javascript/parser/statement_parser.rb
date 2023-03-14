module Javascript
  class Parser::StatementParser
    def initialize(parser:)
      @parser = parser
    end

    def parse_statement
      tokenizer.with_grammar(Grammar::StatementGrammar) do
        case
        when tokenizer.consume("var")      then parse_var_statement
        when tokenizer.consume("let")      then parse_let_statement_or_expression
        when tokenizer.consume("const")    then parse_const_statement
        when tokenizer.consume("if")       then parse_if_statement
        when tokenizer.consume("while")    then parse_while_loop
        when tokenizer.consume("do")       then parse_do_while_loop
        when tokenizer.consume("break")    then parse_break_statement
        when tokenizer.consume("continue") then parse_continue_statement
        when tokenizer.consume("throw")    then parse_throw_statement
        when tokenizer.consume("function") then parse_function_declaration
        when tokenizer.consume("{")        then parse_block
        when tokenizer.consume("return")   then parse_return_statement
        when tokenizer.consume("with")     then parse_with_statement
        when tokenizer.consume("debugger") then parse_debugger_statement
        when tokenizer.consume(";")        then parse_empty_statement
        else
          parse_expression_statement
        end
      end
    end

    private
      attr_reader :parser

      def tokenizer = parser.tokenizer

      def parse_var_statement
        parse_variable_declarations(VarStatement.new(declarations: [])) do |declaration|
          if parser.scope.var?(declaration.name) || !parser.scope.include?(declaration.name)
            parser.scope.vars << declaration.name
          else
            raise SyntaxError
          end
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
          when parser.scope.include?(declaration.name)
            raise SyntaxError
          else
            parser.scope.lets << declaration.name
          end
        end
      end

      def parse_const_statement
        parse_variable_declarations(ConstStatement.new(declarations: [])) do |declaration|
          case
          when declaration.value.nil?
            raise SyntaxError
          when parser.scope.include?(declaration.name)
            raise SyntaxError
          else
            parser.scope.consts << declaration.name
          end
        end
      end

      def parse_variable_declarations(statement)
        terminal do
          loop do
            declaration = parse_variable_declaration
            yield declaration
            statement.declarations << declaration

            break unless tokenizer.consume(:comma)
          end

          statement
        end
      end

      def parse_variable_declaration
        VariableDeclaration.new.tap do |declaration|
          declaration.name  = tokenizer.consume!(:identifier).value
          declaration.value = parser.parse_expression(precedence: 1) if tokenizer.consume("=")
        end
      end

      def parse_if_statement
        If.new \
          condition:   parse_condition,
          consequent:  parse_statement,
          alternative: (parse_statement if tokenizer.consume("else"))
      end

      def parse_while_loop
        While.new condition: parse_condition, body: parse_statement
      end

      def parse_do_while_loop
        DoWhile.new.tap do |loop|
          loop.body      = parse_statement
          loop.condition = parse_condition if tokenizer.consume!("while")
        end
      end

      def parse_condition
        tokenizer.consume!("(")
        parser.parse_expression.tap do
          tokenizer.consume!(")")
        end
      end

      def parse_break_statement
        terminal { Break.new }
      end

      def parse_continue_statement
        terminal { Continue.new }
      end

      def parse_throw_statement
        terminal do
          tokenizer.grammar.with_line_breaks do
            if tokenizer.consume(:line_break)
              raise SyntaxError
            else
              Throw.new(parser.parse_expression)
            end
          end
        end
      end

      def parse_function_declaration
        if tokenizer.peek(:identifier)
          FunctionDeclaration.new(parse_function)
        else
          raise SyntaxError
        end
      end

      def parse_function
        Parser::FunctionParser.new(parser: parser).parse_function
      end

      def parse_block
        parser.in_new_lexical_scope do |scope|
          Block.new.tap do |block|
            block.body   = parser.parse_statement_list(until: -> { tokenizer.consume("}") })
            block.scope  = scope
          end
        end
      end

      def parse_return_statement
        tokenizer.grammar.with_line_breaks do
          if tokenizer.consume(";") || tokenizer.consume(:line_break)
            Return.new
          else
            terminal { Return.new(parser.parse_expression) }
          end
        end
      end

      def parse_with_statement
        With.new expression: parse_condition, body: parse_statement
      end

      def parse_debugger_statement
        terminal { DebuggerStatement.new }
      end

      def parse_empty_statement
        parse_statement unless tokenizer.finished?
      end

      def parse_expression_statement
        terminal { ExpressionStatement.new(parser.parse_expression) }
      end


      def terminal
        yield.tap do
          tokenizer.with_grammar(Grammar::TerminalGrammar) { tokenizer.consume!(:semicolon) }
        end
      end
  end
end
