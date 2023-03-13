module Javascript
  class Grammar::Expression::InfixGrammar < Grammar
    BINARY_OPERATORS     = %w( && || + - * / ** % == === != !== < <= > >= << >> >>> & | ^ ~ , )
    UNARY_OPERATORS      = %w( ++ -- )
    ASSIGNMENT_OPERATORS = %w( = += -= *= /= **= *= %= <<= >>= >>>= &= |= ^= &&= ||= )

    BINARY_OPERATOR     = Regexp.union(BINARY_OPERATORS.sort_by(&:length).reverse)
    UNARY_OPERATOR      = Regexp.union(UNARY_OPERATORS.sort_by(&:length).reverse)
    ASSIGNMENT_OPERATOR = Regexp.union(ASSIGNMENT_OPERATORS.sort_by(&:length).reverse)

    def next_token
      skip_whitespace(preserve_line_breaks: scanner.match?(/\s*#{UNARY_OPERATOR}/))

      case
      when scanner.scan("=")                 then tokenize_equals
      when scanner.scan("?")                 then tokenize_question_mark
      when scanner.scan(ASSIGNMENT_OPERATOR) then :assignment_operator
      when scanner.scan(UNARY_OPERATOR)      then :unary_operator
      when scanner.scan(BINARY_OPERATOR)     then :binary_operator
      when scanner.scan(".")                 then :dot
      when scanner.scan("(")                 then :opening_bracket
      when scanner.scan(")")                 then :closing_bracket
      when scanner.scan("[")                 then :opening_square_bracket
      when scanner.scan("]")                 then :closing_square_bracket
      when scanner.scan(":")                 then :colon
      else
        super
      end
    end

    private
      def tokenize_equals
        if scanner.scan(/==?/)
          :binary_operator
        else
          :assignment_operator
        end
      end

      def tokenize_question_mark
        if scanner.scan(".")
          tokenize_question_mark_dot
        else
          :question_mark
        end
      end

      def tokenize_question_mark_dot
        case scanner.peek(1)
        when "(", "[", START_OF_IDENTIFIER
          :question_mark_dot
        else
          scanner.unscan
          :question_mark
        end
      end
  end
end
