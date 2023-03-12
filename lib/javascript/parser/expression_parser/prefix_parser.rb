module Javascript
  class Parser::ExpressionParser::PrefixParser
    def initialize(parser:)
      @parser = parser
    end

    # FIXME
    def parse_prefix
      case
      when tokenizer.consume("!")         then parse_unary_operation
      when tokenizer.consume("~")         then parse_unary_operation
      when tokenizer.consume("+")         then parse_unary_operation
      when tokenizer.consume("-")         then parse_unary_operation
      when tokenizer.consume("void")      then parse_unary_operation
      when tokenizer.consume("typeof")    then parse_unary_operation
      when tokenizer.consume("++")        then parse_update_operation
      when tokenizer.consume("--")        then parse_update_operation
      when tokenizer.consume("function")  then parse_function_definition
      when tokenizer.consume("new")       then parse_new
      when tokenizer.consume(:identifier) then parse_identifier
      when tokenizer.consume(:string)     then parse_string_literal
      when tokenizer.consume(:number)     then parse_number_literal
      when tokenizer.consume("{")         then parse_object_literal
      when tokenizer.consume("[")         then parse_array_literal
      when tokenizer.consume("(")         then parse_parenthetical
      when tokenizer.consume("true")      then parse_true
      when tokenizer.consume("false")     then parse_false
      when tokenizer.consume("null")      then parse_null
      else
        raise SyntaxError
      end
    end

    private
      attr_reader :parser

      def tokenizer = parser.tokenizer

      def parse_unary_operation
        UnaryOperation.new \
          operator: tokenizer.current_token.value, operand: parser.parse_expression(precedence: 14), position: :prefix
      end

      def parse_update_operation
        operator = tokenizer.current_token.value
        operand  = parser.parse_expression(precedence: 14)

        if operand.is_a?(Identifier) || operand.is_a?(PropertyAccess)
          UnaryOperation.new operator: operator, operand: operand, position: :prefix
        else
          raise SyntaxError
        end
      end

      def parse_function_definition
        Parser::FunctionParser.new(parser: parser).parse_function
      end

      def parse_new
        constructor = parser.parse_expression(precedence: 16)

        if tokenizer.peek("(")
          New.new(parse_function_call(callee: constructor))
        else
          New.new(constructor)
        end
      end

      def parse_function_call(callee:)
        Parser::ExpressionParser::InfixParser.new(parser: parser, prefix: callee, precedence: 0).parse_infix
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
              break unless tokenizer.consume(:comma)
            else
              break
            end
          end

          raise SyntaxError unless tokenizer.consume(:closing_brace)
        end
      end

      def parse_property_definition
        name = tokenizer.current_token.literal || tokenizer.current_token.value
        
        case
        when tokenizer.consume(":") then parse_property_assignment(name: name)
        when tokenizer.consume("(") then parse_method_definition(name: name)
        else                             parse_shorthand_property(name: name)
        end
      end
      
      def parse_property_assignment(name:)
        PropertyDefinition.new name: name, value: parser.parse_expression(precedence: 2)
      end
      
      def parse_method_definition(name:)
        tokenizer.rewind # rewind (
        tokenizer.rewind # rewind name
        
        PropertyDefinition.new name: name, value: parse_function_definition
      end
      
      def parse_shorthand_property(name:)
        PropertyDefinition.new name: name, value: parse_identifier
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
