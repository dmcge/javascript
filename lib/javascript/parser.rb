module Javascript
  Assignment          = Struct.new(:identifier, :value)
  BinaryOperation     = Struct.new(:operator, :left_hand_side, :right_hand_side)
  Block               = Struct.new(:body)
  ExpressionStatement = Struct.new(:expression)
  FunctionCall        = Struct.new(:callee, :arguments)
  FunctionDefinition  = Struct.new(:name, :parameters, :body)
  Identifier          = Struct.new(:name)
  If                  = Struct.new(:condition, :consequent, :alternative)
  Parenthetical       = Struct.new(:expression)
  Return              = Struct.new(:expression)
  StatementList       = Struct.new(:statements)
  UnaryOperation      = Struct.new(:operator, :operand)
  VariableDeclaration = Struct.new(:name, :value)
  VariableStatement   = Struct.new(:declarations, keyword_init: true)

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
        when tokenizer.consume(:return)        then parse_return_statement
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

          if tokenizer.consume(:equals)
            declaration.value = parse_assignment_expression or raise
          end
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
        Block.new(parse_statement_list)
      end

      def parse_statement_list
        StatementList.new(statements: []).tap do |list|
          tokenizer.until(:closing_brace) do
            list.statements << parse_statement
          end
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
        left_hand_side = parse_left_hand_side_expression

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
          parse_assignment_expression
        end
      end

      def parse_unary_operation
        operator = Operator.for(tokenizer.current_token.value)
        UnaryOperation.new(operator, parse_unary_expression)
      end

      def parse_assignment_expression
        expression = parse_left_hand_side_expression

        if tokenizer.consume(:equals)
          if expression.is_a?(Identifier)
            Assignment.new(expression, parse_assignment_expression)
          else
            raise "Syntax error!"
          end
        else
          expression
        end
      end

      def parse_left_hand_side_expression
        expression = parse_primary_expression

        while tokenizer.consume(:opening_bracket)
          expression = FunctionCall.new.tap do |function_call|
            function_call.callee    = expression
            function_call.arguments = parse_arguments
          end
        end

        expression
      end

      def parse_arguments
        [].tap do |arguments|
          tokenizer.until(:closing_bracket) do
            arguments << parse_expression
            tokenizer.consume(:comma)
          end
        end
      end

      def parse_primary_expression
        case
        when tokenizer.consume(:function)        then parse_function_definition
        when tokenizer.consume(:identifier)      then parse_identifier
        when tokenizer.consume(:string)          then parse_string_literal
        when tokenizer.consume(:number)          then parse_number_literal
        when tokenizer.consume(:true)            then parse_true
        when tokenizer.consume(:false)           then parse_false
        when tokenizer.consume(:opening_bracket) then parse_parenthetical
        end
      end

      def parse_function_definition
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
        Identifier.new(tokenizer.current_token.value)
      end

      def parse_string_literal
        String.new(tokenizer.current_token.literal)
      end

      def parse_number_literal
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
