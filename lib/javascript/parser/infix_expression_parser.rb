module Javascript
  class Parser
    class InfixExpressionParser
      attr_reader :prefix, :precedence

      def initialize(parser:, tokenizer:, prefix:, precedence:)
        @parser, @tokenizer, @prefix, @precedence = parser, tokenizer, prefix, precedence
      end

      def parse_expression
        case
        when tokenizer.consume(:operator) then parse_operation
        when tokenizer.consume(:equals)   then parse_assignment
        when tokenizer.consume(:dot)      then parse_property_access_by_name
        when tokenizer.consume("[")       then parse_property_access_by_expression
        when tokenizer.consume("(")       then parse_function_call
        end
      end

      private
        attr_reader :parser, :tokenizer

        def parse_operation
          operator = Operator.for(tokenizer.current_token.value)

          if operator.binary?
            parse_binary_operation(operator)
          else
            parse_unary_operation(operator)
          end
        end

        def parse_binary_operation(operator)
          left_hand_side  = prefix
          right_hand_side = parser.parse_expression(precedence: operator.right_associative? ? precedence - 1 : precedence)

          BinaryOperation.new(operator, left_hand_side, right_hand_side)
        end

        def parse_unary_operation(operator)
          UnaryOperation.new(operand: validate_unary_operand(operator, prefix), operator: operator, position: :postfix)
        end

        def parse_assignment
          if prefix.is_a?(Identifier)
            left_hand_side  = prefix
            right_hand_side = parser.parse_expression(precedence: precedence - 1)

            Assignment.new(left_hand_side, right_hand_side)
          else
            raise SyntaxError
          end
        end

        def parse_property_access_by_name
          PropertyAccess.new.tap do |access|
            access.receiver = prefix
            access.accessor = tokenizer.consume(:identifier).value
            access.computed = true
          end
        end

        def parse_property_access_by_expression
          access = PropertyAccess.new(receiver: prefix, accessor: parser.parse_expression, computed: false)

          if tokenizer.consume("]")
            access
          else
            raise SyntaxError
          end
        end

        def parse_function_call
          FunctionCall.new.tap do |function_call|
            function_call.callee    = prefix
            function_call.arguments = parse_arguments
          end
        end

        def parse_arguments
          [].tap do |arguments|
            tokenizer.until(:closing_bracket) do
              arguments << parser.parse_expression(precedence: precedence)
              tokenizer.consume(:comma)
            end
          end
        end


        def validate_unary_operand(operator, operand)
          case operator
          when Operator::Increment, Operator::Decrement
            if operand.is_a?(Identifier) || operand.is_a?(PropertyAccess)
              operand
            else
              raise SyntaxError
            end
          else
            operand
          end
        end
    end
  end
end
