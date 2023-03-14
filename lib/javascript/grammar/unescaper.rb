module Javascript
  class Grammar::Unescaper
    def initialize(scanner, unescape_legacy_octals: false)
      @scanner, @unescape_legacy_octals = scanner, unescape_legacy_octals
    end

    def consume_escape_sequence
      case
      when scanner.scan(/n|r|t|b|f|v/) then consume_escaped_character
      when scanner.scan(/0(?![0-9])/)  then consume_null_byte
      when scanner.scan("u")           then consume_unicode_escape
      when scanner.scan("x")           then consume_hex_escape
      when scanner.scan(/[0-7]/)       then consume_octal_escape
      else
        scanner.getch
      end
    end

    private
      attr_reader :scanner

      def consume_escaped_character
        %("\\#{scanner.matched}").undump
      end

      def consume_null_byte
        "\0"
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
        if @unescape_legacy_octals
          consume_legacy_octal_escape
        else
          scanner.matched
        end
      end

      def consume_legacy_octal_escape
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
