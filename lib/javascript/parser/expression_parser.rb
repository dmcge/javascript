module Javascript
  class Parser
    class ExpressionParser
      attr_reader :precedence

      def initialize(parser:, tokenizer:, precedence:)
        @parser, @tokenizer, @precedence = parser, tokenizer, precedence
      end

      def parse_expression
        if expression = parse_prefix_expression
          while precedence < (current_precedence = precedence_of(tokenizer.look_ahead))
            expression = parse_infix_expression(expression, precedence: current_precedence)
            break unless expression
          end

          expression
        else
          nil
        end
      end

      private
        attr_reader :parser, :tokenizer

        def parse_prefix_expression
          PrefixExpressionParser.new(parser: parser, tokenizer: tokenizer).parse_expression
        end

        def parse_infix_expression(prefix, precedence:)
          InfixExpressionParser.new(parser: parser, tokenizer: tokenizer, prefix: prefix, precedence: precedence).parse_expression
        end

        def precedence_of(token)
          case token.value
          when ".", "[", "("                                                                                  then 16
          when "++", "--"                                                                                     then 15
          when "**"                                                                                           then 14
          when "*", "/", "%"                                                                                  then 13
          when "+", "-"                                                                                       then 12
          when "<<", ">>", ">>>"                                                                              then 11
          when "<", "<=", ">", ">="                                                                           then 10
          when "==", "!=", "===", "!=="                                                                       then 9
          when "&"                                                                                            then 8
          when "^"                                                                                            then 7
          when "|"                                                                                            then 6
          when "&&"                                                                                           then 5
          when "||"                                                                                           then 4
          when "?"                                                                                            then 3
          when "=", "+=", "-=", "*=", "/=", "**=", "%=", "<<=", ">>=", ">>>=", "&=", "|=", "^=", "&&=", "||=" then 2
          when ","                                                                                            then 1
          else
            0
          end
        end
    end
  end
end
