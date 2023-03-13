module Javascript
  class Grammar
    START_OF_IDENTIFIER = /\p{L}|_|\$/
    IDENTIFIER_CHARACTER = /#{START_OF_IDENTIFIER}|\p{Mn}|\p{Mc}|\p{Nd}|\p{Pc}|\u200c|\u200d/
    KEYWORDS = %w( break const continue debugger do else false function if new null return throw true typeof var void while with )

    def initialize(scanner)
      @scanner = scanner
    end

    def next_token
      case
      when scanner.scan("//")                then tokenize_inline_comment
      when scanner.scan("/*")                then tokenize_block_comment
      when scanner.scan(START_OF_IDENTIFIER) then tokenize_identifier
      when scanner.scan($/)                  then :line_break
      when scanner.eos?                      then :end_of_file
      else
        :unknown
      end
    end

    def skip_whitespace(preserve_line_breaks: false)
      if preserve_line_breaks
        scanner.skip(/[^\S\r\n]+/)
      else
        scanner.skip(/\s+/)
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


      def tokenize_identifier
        scanner.unscan

        identifier = scanner.scan_until(/.(?!#{IDENTIFIER_CHARACTER})/)

        if KEYWORDS.include?(identifier)
          :keyword
        else
          :identifier
        end
      end
  end
end
