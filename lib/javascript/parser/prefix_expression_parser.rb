module Javascript
  class Parser::PrefixExpressionParser
    def initialize(parser:, tokenizer:)
      @parser, @tokenizer = parser, tokenizer
    end

    # FIXME
    def parse_expression
      case
      when tokenizer.consume("!")         then parse_unary_operation
      when tokenizer.consume("~")         then parse_unary_operation
      when tokenizer.consume("+")         then parse_unary_operation
      when tokenizer.consume("-")         then parse_unary_operation
      when tokenizer.consume("++")        then parse_update_operation
      when tokenizer.consume("--")        then parse_update_operation
      when tokenizer.consume(:function)   then parse_function_definition
      when tokenizer.consume(:identifier) then parse_identifier
      when tokenizer.consume(:string)     then parse_string_literal
      when tokenizer.consume(:number)     then parse_number_literal
      when tokenizer.consume("{")         then parse_object_literal
      when tokenizer.consume("[")         then parse_array_literal
      when tokenizer.consume("(")         then parse_parenthetical
      when tokenizer.consume("true")      then parse_true
      when tokenizer.consume("false")     then parse_false
      when tokenizer.consume("null")      then parse_null
      end
    end

    def parse_expression!
      parse_expression or raise SyntaxError
    end

    private
      attr_reader :parser, :tokenizer

      def parse_unary_operation
        UnaryOperation.new operator: tokenizer.current_token.value, operand: parse_expression!, position: :prefix
      end

      def parse_update_operation
        operator = tokenizer.current_token.value
        operand  = parse_expression!

        if operand.is_a?(Identifier) || operand.is_a?(PropertyAccess)
          UnaryOperation.new operator: operator, operand: operand, position: :prefix
        else
          raise SyntaxError
        end
      end

      def parse_function_definition
        Parser::FunctionParser.new(parser: parser, tokenizer: tokenizer).parse_function
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

      def parse_property_definition
        PropertyDefinition.new.tap do |property|
          property.name = tokenizer.current_token.literal || tokenizer.current_token.value

          if tokenizer.consume(:colon)
            property.value = parser.parse_expression(precedence: 2) or raise SyntaxError
          else
            property.value = parse_identifier
          end
        end
      end

      def parse_array_literal
        ArrayLiteral.new(elements: []).tap do |array|
          tokenizer.until(:closing_square_bracket) do
            if tokenizer.consume(:comma)
              array.elements << nil
            else
              array.elements << parser.parse_expression(precedence: 2)
              tokenizer.consume(:comma)
            end
          end
        end
      end

      def parse_parenthetical
        raise SyntaxError if tokenizer.consume(")")

        parser.parse_expression.tap do
          raise SyntaxError unless tokenizer.consume(")")
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
  end
end
