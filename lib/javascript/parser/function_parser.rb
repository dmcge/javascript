module Javascript
  class Parser
    class FunctionParser
      def initialize(parser:, tokenizer:)
        @parser, @tokenizer = parser, tokenizer
      end

      def parse_function
        FunctionDefinition.new.tap do |function|
          function.name = tokenizer.consume(:identifier)&.value
          function.parameters = parse_parameters

          if tokenizer.peek("{")
            function.body = parser.parse_statement
          else
            raise SyntaxError
          end
        end
      end

      private
        attr_reader :parser, :tokenizer

        def parse_parameters
          [].tap do |parameters|
            if tokenizer.consume(:opening_bracket)
              tokenizer.until(:closing_bracket) do
                parameters << parse_parameter
                tokenizer.consume(:comma)
              end
            else
              raise SyntaxError
            end
          end
        end

        def parse_parameter
          Parameter.new.tap do |parameter|
            parameter.name    = tokenizer.consume!(:identifier).value
            parameter.default = parser.parse_expression!(precedence: 2) if tokenizer.consume(:equals)
          end
        end
    end
  end
end
