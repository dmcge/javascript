require "strscan"

module Javascript
  class Tokenizer
    Token = Struct.new(:type, :raw, :literal, :starting_position, :ending_position, keyword_init: true) do
      def value
        raw.strip
      end
    end

    def initialize(javascript)
      @scanner = StringScanner.new(javascript)
      @tokens  = []
    end

    def current_token
      @tokens.last
    end

    def next_token
      advance
      current_token
    end

    def consume(type)
      token = next_token

      if type === token.type
        token
      else
        rewind
        nil
      end
    end

    def until(type)
      loop do
        case
        when consume(type)
          break
        when finished?
          raise "Syntax error!"
        else
          yield
        end
      end
    end

    def rewind
      scanner.pos = tokens.pop.starting_position
    end

    def finished?
      scanner.eos?
    end

    private
      attr_reader :scanner, :tokens

      def advance
        Token.new.tap do |token|
          token.starting_position   = scanner.pos
          token.type, token.literal = advance_to_next_token
          token.ending_position     = scanner.pos
          token.raw                 = scanner.string[token.starting_position...token.ending_position]

          tokens << token
        end
      end

      START_OF_IDENTIFIER = /\p{L}|_|\$/

      def advance_to_next_token
        skip_whitespace
        skip_comments
        skip_whitespace

        case
        when scanner.scan(START_OF_IDENTIFIER) then tokenize_identifier
        when scanner.scan(/\d/)                then tokenize_numeric
        when scanner.scan(/"|'/)               then tokenize_string
        when scanner.scan(",")                 then :comma
        when scanner.scan("(")                 then :opening_bracket
        when scanner.scan(")")                 then :closing_bracket
        when scanner.scan("{")                 then :opening_brace
        when scanner.scan("}")                 then :closing_brace
        when scanner.scan(".")                 then tokenize_dot
        when scanner.scan(/\+|\-/)             then :additive_operator
        when scanner.scan("**")                then :exponentiation_operator
        when scanner.scan(/\*|\/|%/)           then :multiplicative_operator
        when scanner.scan(/<<|>>>|>>/)         then :shift_operator
        when scanner.scan(/[<>]=?/)            then :relational_operator
        when scanner.scan(/==|!=/)             then :equality_operator
        when scanner.scan("=")                 then :equals
        when scanner.scan(";")                 then :semicolon
        when scanner.eos?                      then :semicolon
        else
          raise "Unrecognised character: #{scanner.getch.inspect}"
        end
      end


      def skip_whitespace
        scanner.skip(/\s+/)
      end

      def skip_comments
        case
        when scanner.scan("//") then skip_single_line_comment
        when scanner.scan("/*") then skip_multiline_comment
        end
      end

      def skip_single_line_comment
        scanner.skip_until(/(?=\R)|\Z/)
      end

      def skip_multiline_comment
        if comment = scanner.scan_until(/\*\//)
          insert_line_break if comment.match?(/\R/)
        else
          raise "Syntax error!"
        end
      end

      def insert_line_break
        unless scanner.eos?
          scanner.string[scanner.pos] = "\n" + scanner.string[scanner.pos]
        end
      end


      IDENTIFIER_CHARACTER = /#{START_OF_IDENTIFIER}|\p{Mn}|\p{Mc}|\p{Nd}|\p{Pc}|\u200c|\u200d/
      KEYWORDS = %w( var if else true false function return )

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
          raise "Syntax error!"
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
          fractional = scanner.scan(".") ? consume_integer : 0
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
              raise "Syntax error!" unless digits.last&.match?(pattern) && scanner.peek(1).match?(pattern)
            else
              if digits.none?
                raise "Syntax error!"
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
            raise "Syntax error!"
          when scanner.scan(/\R/)
            raise "Syntax error!"
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
          raise "Syntax error!"
        end
      end

      def consume_hex_escape
        if scanner.scan(/\h{2}/)
          scanner.matched.to_i(16).chr("UTF-8")
        else
          raise "Syntax error!"
        end
      end

      def consume_octal_escape
        String.new.tap do |octal|
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
