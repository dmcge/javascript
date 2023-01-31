module Javascript
  class Grammar
    START_OF_IDENTIFIER = /\p{L}|_|\$/
    OPERATOR            = />>>|===|!==|==|\*\*|>>|<<|<=|>=|!=|&&|\+\+|\-\-|\|\||>|\-|\+|%|\*|<|\/|!|&|\^|\|/

    def initialize(scanner)
      @scanner = scanner
    end

    def next_token
      case
      when scanner.scan("//")                then tokenize_inline_comment
      when scanner.scan("/*")                then tokenize_block_comment
      when scanner.scan(START_OF_IDENTIFIER) then tokenize_identifier
      when scanner.scan(/\d/)                then tokenize_numeric
      when scanner.scan(/"|'/)               then tokenize_string
      when scanner.scan(".")                 then tokenize_dot
      when scanner.scan(",")                 then :comma
      when scanner.scan("(")                 then :opening_bracket
      when scanner.scan(")")                 then :closing_bracket
      when scanner.scan("{")                 then :opening_brace
      when scanner.scan("}")                 then :closing_brace
      when scanner.scan("[")                 then :opening_square_bracket
      when scanner.scan("]")                 then :closing_square_bracket
      when scanner.scan(OPERATOR)            then :operator
      when scanner.scan("=")                 then :equals
      when scanner.scan(":")                 then :colon
      when scanner.scan(";")                 then :semicolon
      when scanner.scan($/)                  then :line_break
      when scanner.scan(/\s+/)               then :whitespace
      when scanner.eos?                      then :semicolon
      else
        raise "Unrecognised character: #{scanner.getch.inspect}"
      end
    end

    private
      attr_reader :scanner

      def skip_comments
        case
        when scanner.scan("//") then skip_single_line_comment
        when scanner.scan("/*") then skip_multiline_comment
        end
      end

      def tokenize_inline_comment
        scanner.scan_until(/(?=\R)|\Z/)
        :comment
      end

      def tokenize_block_comment
        if comment = scanner.scan_until(/\*\//)
          insert_line_break if comment.match?(/\R/)
          :comment
        else
          raise SyntaxError
        end
      end

      def insert_line_break
        scanner.string[scanner.pos] = "\n" + scanner.string[scanner.pos] unless scanner.eos?
      end


      IDENTIFIER_CHARACTER = /#{START_OF_IDENTIFIER}|\p{Mn}|\p{Mc}|\p{Nd}|\p{Pc}|\u200c|\u200d/
      KEYWORDS = %w( var if else true false function return null )

      def tokenize_identifier
        scanner.unscan

        identifier = scanner.scan_until(/.(?!#{IDENTIFIER_CHARACTER})/)

        if KEYWORDS.include?(identifier)
          identifier.to_sym
        else
          :identifier
        end
      end

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
        case
        when scanner.scan(/0x/i)     then consume_nondecimal_number(base: 16)
        when scanner.scan(/0b/i)     then consume_nondecimal_number(base: 2)
        when scanner.scan(/0o/i)     then consume_nondecimal_number(base: 8)
        when scanner.scan(/0(?=\d)/) then consume_potentially_nondecimal_number(base: 8)
        else                              consume_decimal_number
        end
      end

      def consume_nondecimal_number(base:)
        consume_integer(pattern: /#{Regexp.union((Array("0".."9") + Array("a".."z"))[0...base]).source}/i).to_i(base)
      end

      def consume_potentially_nondecimal_number(base:)
        decimal = consume_decimal_number

        if decimal.to_i == decimal
          Integer(decimal.to_i.to_s, base, exception: false) || decimal
        else
          decimal
        end
      end

      def consume_decimal_number
        if scanner.scan(".")
          whole      = 0
          fractional = consume_integer
        else
          whole      = consume_integer
          fractional = scanner.scan(".") && scanner.peek(1).match?(/\d/) ? consume_integer : 0
        end

        exponent = scanner.scan(/e/i) ? consume_signed_integer : 0

        "#{whole}.#{fractional}e#{exponent}".to_f
      end

      def consume_integer(pattern: /\d/)
        [].tap do |digits|
          loop do
            case
            when scanner.scan(pattern)
              digits << scanner.matched
            when scanner.scan("_")
              raise SyntaxError unless digits.last&.match?(pattern) && scanner.peek(1).match?(pattern)
            else
              if digits.none?
                raise SyntaxError
              else
                break
              end
            end
          end
        end.join
      end

      def consume_signed_integer(pattern: /\d/)
        sign    = scanner.scan(/\+|\-/).to_s
        integer = consume_integer(pattern: pattern)

        sign + integer
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

      def tokenize_dot
        if scanner.peek(1).match?(/\d/)
          tokenize_numeric
        else
          :dot
        end
      end
  end
end
