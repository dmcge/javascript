module Javascript
  class Grammar::TerminalGrammar < Grammar
    def next_token
      skip_whitespace preserve_line_breaks: true

      case
      when scanner.scan(";")     then :semicolon
      when scanner.scan(/\R/)    then :semicolon
      when scanner.match?("}")   then :semicolon
      when scanner.scan(/\s*\z/) then :semicolon
      end
    end
  end
end
