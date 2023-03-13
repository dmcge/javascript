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
      else
        super
      end
    end

    private
      def tokenize_numeric
        scanner.unscan

        number = consume_number

        if scanner.scan(START_OF_IDENTIFIER) || scanner.scan(/\d/) || scanner.scan(".")
          raise SyntaxError
        else
          [ :number, number ]
        end
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
          when scanner.scan(/\R/)
            raise SyntaxError
          when scanner.scan("\\")
            string << consume_escape_sequence unless scanner.scan(/\R/)
          else
            string << scanner.getch
          end
        end

        [ :string, string ]
      end

      def consume_escape_sequence
        case
        when scanner.scan(/n|r|t|b|f|v/) then consume_escaped_character
        when scanner.scan("u")           then consume_unicode_escape
        when scanner.scan("x")           then consume_hex_escape
        when scanner.scan(/[0-7]/)       then consume_octal_escape
        else
          scanner.getch
        end
      end

      def consume_escaped_character
        %("\\#{scanner.matched}").undump
      end

      def consume_unicode_escape
        if scanner.scan(/(\h{4})/) || scanner.scan(/{(\h{1,6})}/)
          scanner.captures[0].to_i(16).chr("UTF-8")
        else
          raise SyntaxError
        end
      end

      def consume_hex_escape
        if scanner.scan(/\h{2}/)
          scanner.matched.to_i(16).chr("UTF-8")
        else
          raise SyntaxError
        end
      end

      def consume_octal_escape
        ::String.new.tap do |octal|
          octal << scanner.matched

          case scanner.matched.to_i
          when 0..3
            octal << scanner.scan(/[0-7]{1,2}/).to_s
          when 4..7
            octal << scanner.scan(/[0-7]{1}/).to_s
          end
        end.to_i(8).chr("UTF-8")
      end
  end
end
