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

        case
        # FIXME: this isn’t at all correct
        when scanner.scan(/;|\R|\z/)           then :semicolon

        when scanner.scan(START_OF_IDENTIFIER) then tokenize_identifier
        when scanner.scan(/\d/)                then tokenize_numeric
        when scanner.scan(/"|'/)               then tokenize_string
        when scanner.scan(",")                 then :comma
        when scanner.scan("(")                 then :opening_bracket
        when scanner.scan(")")                 then :closing_bracket
        when scanner.scan("{")                 then :opening_brace
        when scanner.scan("}")                 then :closing_brace
        when scanner.scan(".")                 then tokenize_dot
        when scanner.scan("+")                 then :additive_operator
        when scanner.scan("-")                 then :additive_operator
        when scanner.scan("**")                then :exponentiation_operator
        when scanner.scan("*")                 then :multiplicative_operator
        when scanner.scan("/")                 then :multiplicative_operator
        when scanner.scan("%")                 then :multiplicative_operator
        when scanner.scan("<<")                then :shift_operator
        when scanner.scan(">>>")               then :shift_operator
        when scanner.scan(">>")                then :shift_operator
        when scanner.scan(">=")                then :relational_operator
        when scanner.scan(">")                 then :relational_operator
        when scanner.scan("<=")                then :relational_operator
        when scanner.scan("<")                 then :relational_operator
        when scanner.scan("==")                then :equality_operator
        when scanner.scan("!=")                then :equality_operator
        when scanner.scan("=")                 then :equals
        else
          raise "Unrecognised character: #{scanner.getch.inspect}"
        end
      end


      def skip_whitespace
        scanner.skip(/[[:blank:]]+/)
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
        tokenize_number
      end

      def tokenize_number
        [ :number, tokenize_number_literal ]
      end

      def tokenize_number_literal
        case
        when scanner.scan(/0x/i)     then tokenize_nondecimal_number(base: 16, pattern: /\h/)
        when scanner.scan(/0b/i)     then tokenize_nondecimal_number(base: 2)
        when scanner.scan(/0o/i)     then tokenize_nondecimal_number(base: 8)
        when scanner.scan(/0(?=\d)/) then tokenize_potentially_nondecimal_number(base: 8)
        else                              tokenize_decimal_number
        end
      end

      def tokenize_nondecimal_number(base:, pattern: /[0-#{base - 1}]/)
        digits = []

        loop do
          case
          when scanner.scan(/[[:alnum:]]/)
            if scanner.matched.match?(pattern)
              digits << scanner.matched
            else
              raise "Syntax error!"
            end
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

        digits.join.to_i(base).to_f
      end

      def tokenize_potentially_nondecimal_number(base:)
        decimal = tokenize_decimal_number

        if decimal.to_i == decimal
          Integer(decimal.to_i.to_s, base, exception: false) || decimal
        else
          decimal
        end
      end

      def tokenize_decimal_number
        digits = []

        loop do
          case
          when scanner.scan(/\d/)
            digits << scanner.matched
          when scanner.scan(".")
            # TODO: probably won’t need to raise when dot parsing is implemented proper
            if !digits.include?(".") && scanner.peek(1).match?(/\d/)
              digits << scanner.matched
            else
              raise "Syntax error!"
            end
          when scanner.scan("_")
            raise "Syntax error!" unless digits.last&.match?(/\d/) && scanner.peek(1).match?(/\d/)
          when scanner.scan(/e/i)
            case
            when digits.include?("e") || digits.include?("E")
              raise "Syntax error!"
            else
              digits << scanner.matched
            end
          # TODO: probably won’t need this case eventually
          when scanner.scan(/[a-z]/i)
            raise "Syntax error!"
          when scanner.scan(/[+-]/)
            if digits.last.casecmp?("e")
              digits << scanner.matched
            # TODO: probably won’t need this when dot parsing is implemented proper
            elsif digits.last == "."
              raise "Syntax error!"
            else
              scanner.unscan
              break
            end
          else
            # TODO: just break when dot parsing is implemented proper
            case digits.last
            when ".", /e/i
              raise "Syntax error!"
            else
              break
            end
          end
        end

        digits.join.to_f
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
