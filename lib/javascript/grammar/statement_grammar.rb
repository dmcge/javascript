module Javascript
  class Grammar::StatementGrammar < Grammar
    def next_token
      skip_whitespace(preserve_line_breaks: @preserve_line_breaks)

      case
      when scanner.scan("=") then :equals
      when scanner.scan(",") then :comma
      when scanner.scan("(") then :opening_bracket
      when scanner.scan(")") then :closing_bracket
      when scanner.scan("{") then :opening_brace
      when scanner.scan("}") then :closing_brace
      when scanner.scan(":") then :colon
      when scanner.scan(";") then :semicolon
      else
        super
      end
    end

    def with_line_breaks
      had_line_breaks = @preserve_line_breaks
      @preserve_line_breaks = true
      yield
    ensure
      @preserve_line_breaks = had_line_breaks
    end
  end
end
