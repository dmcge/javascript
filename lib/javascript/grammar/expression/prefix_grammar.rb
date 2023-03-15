module Javascript
  class Grammar::Expression::PrefixGrammar < Grammar
    UPDATE_OPERATOR = Regexp.union(%w( ++ -- ).sort_by(&:length).reverse)
    UNARY_OPERATOR  = Regexp.union(%w( ! ~ + - void typeof ).sort_by(&:length).reverse)

    def next_token
      skip_whitespace

      case
      when scanner.scan(/\.?\d/)         then tokenize_numeric
      when scanner.scan(/"|'/)           then tokenize_string
      when scanner.scan(UPDATE_OPERATOR) then :update_operator
      when scanner.scan(UNARY_OPERATOR)  then :unary_operator
      when scanner.scan(",")             then :comma
      when scanner.scan("(")             then :opening_bracket
      when scanner.scan(")")             then :closing_bracket
      when scanner.scan("{")             then :opening_brace
      when scanner.scan("}")             then :closing_brace
      when scanner.scan("[")             then :opening_square_bracket
      when scanner.scan("]")             then :closing_square_bracket
      when scanner.scan(":")             then :colon
      when scanner.scan("`")             then :backtick
      else
        super
      end
    end

    private
      def tokenize_numeric
        scanner.unscan
        [ :number, consume_number ]
      end

      def consume_number
        Grammar::NumberConsumer.new(scanner).consume_number
      end

      def tokenize_string
        quotation_mark = scanner.matched
        string = ::String.new

        loop do
          case
          when scanner.scan(quotation_mark)
            break
          when scanner.eos?
            raise SyntaxError
          when scanner.scan(LINE_BREAK)
            raise SyntaxError
          when scanner.scan("\\")
            string << consume_escape_sequence unless scanner.scan(LINE_BREAK)
          else
            string << scanner.getch
          end
        end

        [ :string, string ]
      end

      def consume_escape_sequence
        Grammar::Unescaper.new(scanner, unescape_legacy_octals: true).consume_escape_sequence
      end
  end
end
