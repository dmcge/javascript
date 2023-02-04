require "javascript/tokenizer/grammar/number_consumer"

module Javascript
  class Grammar
    START_OF_IDENTIFIER = /\p{L}|_|\$/

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
      when scanner.scan("&")                 then tokenize_ampersand
      when scanner.scan("|")                 then tokenize_pipe
      when scanner.scan("=")                 then tokenize_equals
      when scanner.scan("+")                 then tokenize_plus
      when scanner.scan("-")                 then tokenize_minus
      when scanner.scan("*")                 then tokenize_star
      when scanner.scan("!")                 then tokenize_exclamation_mark
      when scanner.scan("<")                 then tokenize_left_caret
      when scanner.scan(">")                 then tokenize_right_caret
      when scanner.scan("^")                 then :up_caret
      when scanner.scan("/")                 then :forward_slash
      when scanner.scan(",")                 then :comma
      when scanner.scan("%")                 then :percent
      when scanner.scan("~")                 then :tilde
      when scanner.scan("(")                 then :opening_bracket
      when scanner.scan(")")                 then :closing_bracket
      when scanner.scan("{")                 then :opening_brace
      when scanner.scan("}")                 then :closing_brace
      when scanner.scan("[")                 then :opening_square_bracket
      when scanner.scan("]")                 then :closing_square_bracket
      when scanner.scan("?")                 then :question_mark
      when scanner.scan(":")                 then :colon
      when scanner.scan(";")                 then :semicolon
      when scanner.scan($/)                  then :line_break
      when scanner.scan(/\s+/)               then :whitespace
      when scanner.eos?                      then :end_of_file
      else
        raise SyntaxError, "Unrecognised character: #{scanner.getch.inspect}"
      end
    end

    private
      attr_reader :scanner

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
        NumberConsumer.new(scanner).consume_number
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

      def tokenize_ampersand
        if scanner.scan("&")
          :ampersand_ampersand
        else
          :ampersand
        end
      end

      def tokenize_pipe
        if scanner.scan("|")
          :pipe_pipe
        else
          :pipe
        end
      end

      def tokenize_equals
        case
        when scanner.scan("==")
          :equals_equals_equals
        when scanner.scan("=")
          :equals_equals
        else
          :equals
        end
      end

      def tokenize_plus
        if scanner.scan("+")
          :plus_plus
        else
          :plus
        end
      end

      def tokenize_minus
        if scanner.scan("-")
          :minus_minus
        else
          :minus
        end
      end

      def tokenize_star
        if scanner.scan("*")
          :star_star
        else
          :star
        end
      end

      def tokenize_exclamation_mark
        case
        when scanner.scan("==")
          :exclamation_equals_equals
        when scanner.scan("=")
          :exclamation_equals
        else
          :exclamation_mark
        end
      end

      def tokenize_left_caret
        case
        when scanner.scan("<")
          :left_caret_caret
        when scanner.scan("=")
          :left_caret_equals
        else
          :left_caret
        end
      end

      def tokenize_right_caret
        case
        when scanner.scan(">>")
          :right_caret_caret_caret
        when scanner.scan(">")
          :right_caret_caret
        when scanner.scan("=")
          :right_caret_equals
        else
          :right_caret
        end
      end
  end
end
