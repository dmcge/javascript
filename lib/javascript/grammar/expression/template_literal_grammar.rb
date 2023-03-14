module Javascript
  class Grammar::Expression::TemplateLiteralGrammar < Grammar
    def next_token
      case
      when scanner.scan("`")  then :backtick
      when scanner.scan("${") then :opening_brace
      when scanner.scan("}")  then :closing_brace
      else
        tokenize_content
      end
    end

    private
      def tokenize_content
        [ :content, consume_content ]
      end

      def consume_content
        ::String.new.tap do |content|
          loop do
            case
            when scanner.match?(/`|\${/)
              break
            when scanner.eos?
              raise SyntaxError
            when scanner.scan("\\")
              content << consume_escape_sequence unless scanner.scan(LINE_BREAK)
            else
              content << scanner.getch
            end
          end
        end
      end

      def consume_escape_sequence
        Grammar::Unescaper.new(scanner).consume_escape_sequence
      end
  end
end
