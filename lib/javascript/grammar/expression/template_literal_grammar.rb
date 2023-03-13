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
        if content = scanner.scan_until(/(?=`|\${)/)
          content.gsub!(/\\#{LINE_BREAK}/, "")
          content
        else
          raise SyntaxError
        end
      end
  end
end
