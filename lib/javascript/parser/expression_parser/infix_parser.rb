module Javascript
  class Parser::ExpressionParser::InfixParser
    RIGHT_ASSOCIATIVE_OPERATORS = %w( ** )
    LEFT_ASSOCIATIVE_OPERATORS  = %w( / * + - , % == === != !== < <= > >= << >> >>> && || & | ^ )
    UNARY_OPERATORS             = %w( ++ -- )
    ASSIGNMENT_OPERATORS        = %w( = += -= *= /= **= *= %= <<= >>= >>>= &= |= ^= &&= ||= )
    
    attr_reader :prefix, :precedence

    def initialize(parser:, prefix:, precedence:)
      @parser, @prefix, @precedence = parser, prefix, precedence
    end

    def parse_infix
      case
      when tokenizer.consume(RIGHT_ASSOCIATIVE_OPERATORS) then parse_rightward_binary_operation
      when tokenizer.consume(LEFT_ASSOCIATIVE_OPERATORS)  then parse_leftward_binary_operation
      when tokenizer.consume(UNARY_OPERATORS)             then parse_unary_operation
      when tokenizer.consume(ASSIGNMENT_OPERATORS)        then parse_assignment
      when tokenizer.consume("?.")                        then parse_optional_chaining
      when tokenizer.consume(".")                         then parse_property_access_with_dot
      when tokenizer.consume("[")                         then parse_property_access_with_square_brackets
      when tokenizer.consume("(")                         then parse_function_call
      when tokenizer.consume("?")                         then parse_ternary
      end
    end

    private
      attr_reader :parser

      def tokenizer = parser.tokenizer

      def parse_leftward_binary_operation
        parse_binary_operation(precedence: precedence)
      end

      def parse_rightward_binary_operation
        parse_binary_operation(precedence: precedence - 1)
      end

      def parse_binary_operation(precedence:)
        BinaryOperation.new \
          operator:        tokenizer.current_token.value,
          left_hand_side:  prefix,
          right_hand_side: parser.parse_expression(precedence: precedence)
      end

      def parse_unary_operation
        tokenizer.rewind

        if tokenizer.consume(:line_break)
          tokenizer.insert_semicolon
          prefix
        else
          tokenizer.next_token
          parse_update_operation
        end
      end

      def parse_update_operation
        if prefix.is_a?(Identifier) || prefix.is_a?(PropertyAccess)
          UnaryOperation.new operator: tokenizer.current_token.value, operand: prefix, position: :postfix
        else
          raise SyntaxError
        end
      end

      def parse_assignment
        case prefix
        when Identifier, PropertyAccess
          operator = tokenizer.current_token.value.delete_suffix("=")

          Assignment.new \
            operator: operator.empty? ? nil : operator,
            left_hand_side: prefix,
            right_hand_side: parser.parse_expression(precedence: precedence - 1)
        else
          raise SyntaxError
        end
      end
      
      def parse_optional_chaining
        case
        when tokenizer.consume("(")
          OptionalChain.new receiver: prefix, expression: parse_function_call
        when tokenizer.consume("[")
          OptionalChain.new receiver: prefix, expression: parse_property_access_with_square_brackets
        else
          OptionalChain.new receiver: prefix, expression: parse_property_access_with_dot
        end
      end

      def parse_property_access_with_dot
        PropertyAccess.new(receiver: prefix, accessor: tokenizer.consume!(:identifier).value, computed: true)
      end

      def parse_property_access_with_square_brackets
        PropertyAccess.new(receiver: prefix, accessor: parser.parse_expression, computed: false).tap do
          tokenizer.consume!("]")
        end
      end

      def parse_function_call
        FunctionCall.new(callee: prefix, arguments: parse_arguments)
      end

      def parse_arguments
        [].tap do |arguments|
          tokenizer.until(:closing_bracket) do
            arguments << parse_argument
            tokenizer.consume(:comma)
          end
        end
      end
      
      def parse_argument
        if tokenizer.consume("...")
          Spread.new parser.parse_expression(precedence: 2)
        else
          parser.parse_expression(precedence: 2)
        end
      end

      def parse_ternary
        Ternary.new.tap do |ternary|
          ternary.condition   = prefix
          ternary.consequent  = parser.parse_expression(precedence: 2)
          ternary.alternative = parser.parse_expression(precedence: 2) if tokenizer.consume!(":")
        end
      end
  end
end
