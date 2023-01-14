module Javascript
  StatementList = Struct.new(:statements)
  FunctionDefinition = Struct.new(:name, :parameters, :body)
  FunctionCall = Struct.new(:name, :arguments)
  VariableStatement = Struct.new(:declarations, keyword_init: true)
  Return = Struct.new(:expression)
  VariableDeclaration = Struct.new(:name, :value)
  Reference = Struct.new(:name)
  ExpressionStatement = Struct.new(:expression)
  Parenthetical = Struct.new(:expression)
  If = Struct.new(:condition, :consequent, :alternative)
  Block = Struct.new(:body)
  BinaryOperation = Struct.new(:operator, :left_hand_side, :right_hand_side)
  UnaryOperation = Struct.new(:operator, :operand)

  class Parser
    def initialize(javascript)
      @tokenizer = Tokenizer.new(javascript)
    end

    def parse
      StatementList.new(statements: []).tap do |list|
        list.statements << parse_statement until tokenizer.finished?
      end
    end

    private
      attr_reader :tokenizer

      def parse_statement
        case
        when tokenizer.consume(:var)           then parse_variable_statement
        when tokenizer.consume(:if)            then parse_if_statement
        when tokenizer.consume(:opening_brace) then parse_block
        when tokenizer.consume(:return)        then parse_return
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
        Block.new(parse_statement_list)
      end

      def parse_statement_list
        StatementList.new(statements: []).tap do |list|
          tokenizer.until(:closing_brace) do
            list.statements << parse_statement
          end
        end
      end

      def parse_return
        Return.new(parse_expression)
      end

      def parse_empty_statement
        parse_statement unless tokenizer.finished?
      end

      def parse_expression_statement
        ExpressionStatement.new(parse_expression).tap do
          tokenizer.consume(:semicolon)
        end
      end

      def parse_expression
        parse_equality_expression # || …
      end

      def parse_equality_expression
        left_hand_side = parse_relational_expression

        if tokenizer.consume(:equality_operator)
          operator        = Operator.for(tokenizer.current_token.value)
          right_hand_side = parse_equality_expression

          BinaryOperation.new(operator, left_hand_side, right_hand_side)
        else
          left_hand_side
        end
      end

      def parse_relational_expression
        left_hand_side = parse_shift_expression

        if tokenizer.consume(:relational_operator)
          operator        = Operator.for(tokenizer.current_token.value)
          right_hand_side = parse_relational_expression

          BinaryOperation.new(operator, left_hand_side, right_hand_side)
        else
          left_hand_side
        end
      end

      def parse_shift_expression
        left_hand_side = parse_additive_expression

        if tokenizer.consume(:shift_operator)
          operator        = Operator.for(tokenizer.current_token.value)
          right_hand_side = parse_shift_expression

          BinaryOperation.new(operator, left_hand_side, right_hand_side)
        else
          left_hand_side
        end
      end

      def parse_additive_expression
        left_hand_side = parse_multiplicative_expression

        if tokenizer.consume(:additive_operator)
          operator        = Operator.for(tokenizer.current_token.value)
          right_hand_side = parse_additive_expression

          BinaryOperation.new(operator, left_hand_side, right_hand_side)
        else
          left_hand_side
        end
      end

      def parse_multiplicative_expression
        left_hand_side = parse_exponentiation_expression

        if tokenizer.consume(:multiplicative_operator)
          operator        = Operator.for(tokenizer.current_token.value)
          right_hand_side = parse_multiplicative_expression

          BinaryOperation.new(operator, left_hand_side, right_hand_side)
        else
          left_hand_side
        end
      end

      def parse_exponentiation_expression
        current_token  = tokenizer.current_token
        left_hand_side = parse_primary_expression

        if left_hand_side && tokenizer.consume(:exponentiation_operator)
          right_hand_side = parse_exponentiation_expression

          BinaryOperation.new(Operator.for("**"), left_hand_side, right_hand_side)
        else
          tokenizer.rewind until tokenizer.current_token == current_token
          parse_unary_expression
        end
      end

      def parse_unary_expression
        if tokenizer.consume(:additive_operator)
          parse_unary_operation
        else
          parse_primary_expression
        end
      end

      def parse_unary_operation
        operator = Operator.for(tokenizer.current_token.value)
        UnaryOperation.new(operator, parse_unary_expression)
      end

      def parse_primary_expression
        case
        when tokenizer.consume(:function)        then parse_function
        when tokenizer.consume(:identifier)      then parse_identifier
        when tokenizer.consume(:string)          then parse_string
        when tokenizer.consume(:number)          then parse_number
        when tokenizer.consume(:true)            then parse_true
        when tokenizer.consume(:false)           then parse_false
        when tokenizer.consume(:opening_bracket) then parse_parenthetical
        end
      end

      def parse_function
        FunctionDefinition.new.tap do |function|
          function.name = tokenizer.consume(:identifier)&.value
          function.parameters = parse_parameters

          if tokenizer.consume(:opening_brace)
            function.body = parse_block
          else
            raise "Syntax error!"
          end
        end
      end

      def parse_parameters
        [].tap do |parameters|
          if tokenizer.consume(:opening_bracket)
            tokenizer.until(:closing_bracket) do
              parameters << tokenizer.consume(:identifier).value
              tokenizer.consume(:comma)
            end
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
        Number.new(tokenizer.current_token.literal)
      end

      def parse_true
        True.new
      end

      def parse_false
        False.new
      end

      def parse_parenthetical
        raise "Syntax error!" if tokenizer.consume(:closing_bracket)

        Parenthetical.new(parse_expression).tap do
          raise "Syntax error!" unless tokenizer.consume(:closing_bracket)
        end
      end
  end
end
