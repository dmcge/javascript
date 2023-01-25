module Javascript
  class Parser
    def initialize(javascript)
      @tokenizer = Tokenizer.new(javascript)
    end

    def parse
      parse_statement_list until: -> { tokenizer.finished? }
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
            declaration.value = parse_expression or raise
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
          raise SyntaxError
        end
      end

      def parse_block
        Block.new(parse_statement_list(until: -> { tokenizer.consume(:closing_brace) }))
      end

      def parse_statement_list(until:)
        StatementList.new(statements: []).tap do |list|
          list.statements << parse_statement until binding.local_variable_get(:until).call
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


      def parse_expression(precedence: 0)
        expression = parse_prefix_expression

        unless tokenizer.consume(:semicolon)
          while precedence < (current_precedence = precedence_of(tokenizer.look_ahead))
            expression = parse_infix_expression(expression, precedence: current_precedence)
          end
        end

        expression
      end

      def precedence_of(token)
        case token.value
        when "(", "."                 then 8
        when "**"                     then 7
        when "*", "/", "%"            then 6
        when "+", "-"                 then 5
        when "<<", ">>", ">>>"        then 4
        when "<", "<=", ">", ">="     then 3
        when "==", "!=", "===", "!==" then 2
        when "="                      then 1
        else
          0
        end
      end


      def parse_prefix_expression
        case
        when tokenizer.consume(:operator)               then parse_unary_operation
        when tokenizer.consume(:function)               then parse_function_definition
        when tokenizer.consume(:identifier)             then parse_identifier
        when tokenizer.consume(:string)                 then parse_string_literal
        when tokenizer.consume(:number)                 then parse_number_literal
        when tokenizer.consume(:opening_brace)          then parse_object_literal
        when tokenizer.consume(:opening_square_bracket) then parse_array_literal
        when tokenizer.consume(:opening_bracket)        then parse_parenthetical
        when tokenizer.consume(:true)                   then parse_true
        when tokenizer.consume(:false)                  then parse_false
        when tokenizer.consume(:null)                   then parse_null
        end
      end

      def parse_unary_operation
        if (operator = Operator.for(tokenizer.current_token.value)).unary?
          UnaryOperation.new.tap do |operation|
            operation.operator = operator
            operation.operand  = parse_prefix_expression
          end
        else
          raise SyntaxError
        end
      end

      def parse_function_definition
        FunctionDefinition.new.tap do |function|
          function.name = tokenizer.consume(:identifier)&.value
          function.parameters = parse_parameters

          if tokenizer.consume(:opening_brace)
            function.body = parse_block
          else
            raise SyntaxError
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
            raise SyntaxError
          end
        end
      end

      def parse_identifier
        Identifier.new(tokenizer.current_token.value)
      end

      def parse_string_literal
        StringLiteral.new(tokenizer.current_token.literal)
      end

      def parse_number_literal
        NumberLiteral.new(tokenizer.current_token.literal)
      end

      def parse_object_literal
        ObjectLiteral.new(properties: []).tap do |object|
          loop do
            if tokenizer.consume(:identifier) || tokenizer.consume(:string) || tokenizer.consume(:number)
              object.properties << parse_property_definition

              unless tokenizer.consume(:comma)
                if tokenizer.consume(:closing_brace)
                  break
                else
                  raise SyntaxError
                end
              end
            else
              if tokenizer.consume(:closing_brace)
                break
              else
                raise SyntaxError
              end
            end
          end
        end
      end

      def parse_array_literal
        ArrayLiteral.new(elements: []).tap do |array|
          tokenizer.until(:closing_square_bracket) do
            if tokenizer.consume(:comma)
              array.elements << nil
            else
              array.elements << parse_expression
              tokenizer.consume(:comma)
            end
          end
        end
      end

      def parse_property_definition
        PropertyDefinition.new.tap do |property|
          property.name = tokenizer.current_token.literal || tokenizer.current_token.value

          if tokenizer.consume(:colon)
            property.value = parse_expression or raise SyntaxError
          else
            property.value = parse_identifier
          end
        end
      end

      def parse_parenthetical
        raise SyntaxError if tokenizer.consume(:closing_bracket)

        Parenthetical.new(parse_expression).tap do
          raise SyntaxError unless tokenizer.consume(:closing_bracket)
        end
      end

      def parse_true
        BooleanLiteral.new(value: true)
      end

      def parse_false
        BooleanLiteral.new(value: false)
      end

      def parse_null
        NullLiteral.new
      end


      def parse_infix_expression(prefix, precedence:)
        case
        when tokenizer.consume(:operator)        then parse_binary_operation(prefix, precedence: precedence)
        when tokenizer.consume(:equals)          then parse_assignment(prefix, precedence: precedence)
        when tokenizer.consume(:dot)             then parse_property_access(prefix, precedence: precedence)
        when tokenizer.consume(:opening_bracket) then parse_function_call(prefix, precedence: precedence)
        end
      end

      def parse_binary_operation(left_hand_side, precedence:)
        operator        = Operator.for(tokenizer.current_token.value)
        right_hand_side = parse_expression(precedence: operator.right_associative? ? precedence - 1 : precedence)

        BinaryOperation.new(operator, left_hand_side, right_hand_side)
      end

      def parse_assignment(left_hand_side, precedence:)
        if left_hand_side.is_a?(Identifier)
          right_hand_side = parse_expression(precedence: precedence - 1)

          Assignment.new(left_hand_side, right_hand_side)
        else
          raise SyntaxError
        end
      end

      def parse_property_access(receiver, precedence:)
        PropertyAccess.new.tap do |property_access|
          property_access.receiver = receiver
          property_access.name     = tokenizer.consume(:identifier).value
        end
      end

      def parse_function_call(callee, precedence:)
        FunctionCall.new.tap do |function_call|
          function_call.callee    = callee
          function_call.arguments = parse_arguments(precedence:)
        end
      end

      def parse_arguments(precedence:)
        [].tap do |arguments|
          tokenizer.until(:closing_bracket) do
            arguments << parse_expression(precedence: precedence)
            tokenizer.consume(:comma)
          end
        end
      end
  end
end
