module Javascript
  class Parser::ExpressionParser
    attr_reader :precedence

    def initialize(parser:, precedence:)
      @parser, @precedence = parser, precedence
    end

    def parse_expression
      expression = parse_prefix

      while precedence < (current_precedence = precedence_of(parser.tokenizer.look_ahead))
        expression = parse_infix(expression, precedence: current_precedence)
      end

      expression
    end

    private
      attr_reader :parser

      def parse_prefix
        PrefixParser.new(parser: parser).parse_prefix
      end

      def parse_infix(prefix, precedence:)
        InfixParser.new(parser: parser, prefix: prefix, precedence: precedence).parse_infix
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
