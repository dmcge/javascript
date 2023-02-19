module Javascript
  class Parser
    class FunctionParser
      def initialize(parser:, tokenizer:)
        @parser, @tokenizer = parser, tokenizer
      end

      def parse_function
        parser.in_new_scope do
          FunctionDefinition.new \
            name:       parse_identifier,
            parameters: parse_parameters,
            body:       parse_block,
            variables:  parser.variables
        end
      end

      private
        attr_reader :parser, :tokenizer

        def parse_identifier
          tokenizer.consume(:identifier)&.value
        end

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

        def parse_block
          if tokenizer.peek("{")
            parser.parse_statement
          else
            raise SyntaxError
          end
        end
    end
  end
end
