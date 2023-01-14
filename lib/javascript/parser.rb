module Javascript
  FunctionDefinition = Struct.new(:name, :parameters, :body)
  FunctionCall = Struct.new(:name, :arguments)
  VariableStatement = Struct.new(:declarations, keyword_init: true)
  VariableDeclaration = Struct.new(:name, :value)
  Reference = Struct.new(:name)
  ExpressionStatement = Struct.new(:expression)
  Parenthetical = Struct.new(:expression)
  If = Struct.new(:condition, :consequent, :alternative)
  Block = Struct.new(:statements)

  class Parser
    def initialize(javascript)
      @tokenizer = Tokenizer.new(javascript)
    end

    def parse
      [].tap do |statements|
        statements << parse_statement until tokenizer.finished?
      end
    end

    private
      attr_reader :tokenizer

      def parse_statement
        case
        when tokenizer.consume(:var)           then parse_variable_statement
        when tokenizer.consume(:if)            then parse_if_statement
        when tokenizer.consume(:opening_brace) then parse_block
        when tokenizer.consume(:semicolon)     then parse_empty_statement
        else
          parse_expression_statement
        end
      end

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
          declaration.name  = tokenizer.consume(:identifier).value
          declaration.value = parse_expression if tokenizer.consume(:equals)
        end
      end


      def parse_if_statement
        If.new.tap do |if_statement|
          if_statement.condition   = parse_condition
          if_statement.consequent  = parse_statement
          if_statement.alternative = parse_statement if tokenizer.consume(:else)
        end
      end

      def parse_condition
        if tokenizer.consume(:opening_bracket)
          parse_parenthetical.expression
        else
          raise "Syntax error!"
        end
      end

      def parse_block
        tokenizer.consume(:semicolon) # FIXME

        Block.new(statements: []).tap do |block|
          tokenizer.until(:closing_brace) do
            block.statements << parse_statement
          end
        end
      end

      def parse_empty_statement
        parse_statement unless tokenizer.finished?
      end

      def parse_expression_statement
        @previous_expression = nil
        @previous_expression = parse_expression until tokenizer.finished? || tokenizer.consume(:semicolon)

        ExpressionStatement.new(@previous_expression)
      ensure
        @previous_expression = nil
      end


      def parse_expression
        case
        when tokenizer.consume(:function)        then parse_function
        when tokenizer.consume(:identifier)      then parse_identifier
        when tokenizer.consume(:string)          then parse_string
        when tokenizer.consume(:number)          then parse_number
        when tokenizer.consume(:true)            then parse_true
        when tokenizer.consume(:false)           then parse_false
        when tokenizer.consume(:operator)        then parse_operation
        when tokenizer.consume(:opening_bracket) then parse_parenthetical
        else
          raise "Can’t parse #{tokenizer.next_token.inspect}"
        end
      end

      def parse_function
        FunctionDefinition.new.tap do |function|
          function.name = tokenizer.consume(:identifier)&.value
          function.parameters = []

          if tokenizer.consume(:opening_bracket)
            tokenizer.until(:closing_bracket) do
              function.parameters << tokenizer.consume(:identifier).value
              tokenizer.consume(:comma)
            end
          else
            raise "Syntax error!"
          end

          if tokenizer.consume(:opening_brace)
            function.body = parse_block
          else
            raise "Syntax error!"
          end
        end
      end

      def parse_identifier
        identifier = tokenizer.current_token.value

        if tokenizer.consume(:opening_bracket)
          FunctionCall.new.tap do |function_call|
            function_call.name = identifier
            function_call.arguments = []

            tokenizer.until(:closing_bracket) do
              function_call.arguments << parse_expression
              tokenizer.consume(:comma)
            end
          end
        else
          Reference.new(identifier)
        end
      end

      def parse_string
        String.new(tokenizer.current_token.literal)
      end

      def parse_number
        if @previous_expression.nil?
          Number.new(tokenizer.current_token.literal)
        else
          raise "Syntax error!"
        end
      end

      def parse_true
        True.new
      end

      def parse_false
        False.new
      end

      def parse_operation
        if @previous_expression
          parse_binary_operation
        else
          parse_unary_operation
        end
      end

      def parse_unary_operation
        operator = Operator.for(tokenizer.current_token.value)

        if operator.unary? && operand = parse_expression
          UnaryOperation.new(operator, operand)
        else
          raise "Syntax error!"
        end
      end

      def parse_binary_operation
        left_hand_side  = @previous_expression
        @previous_expression = nil
        operator        = Operator.for(tokenizer.current_token.value)
        right_hand_side = parse_expression

        if left_hand_side && right_hand_side
          BinaryOperation.new(operator, left_hand_side, right_hand_side)
        else
          raise "Syntax error!"
        end
      end

      def parse_parenthetical
        raise "Syntax error!" if tokenizer.consume(:closing_bracket)

        previous_expression  = @previous_expression
        @previous_expression = nil

        Parenthetical.new.tap do |parenthetical|
          tokenizer.until(:closing_bracket) do
            if tokenizer.consume(:semicolon)
              raise "Semicolon!"
            else
              @previous_expression = parse_expression
            end
          end

          parenthetical.expression = @previous_expression
        ensure
          @previous_expression = previous_expression
        end
      end
  end
end
