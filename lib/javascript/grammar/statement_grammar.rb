module Javascript
  class Grammar::StatementGrammar < Grammar
    def next_token
      case
      when scanner.scan("=")                 then :equals
      when scanner.scan(",")                 then :comma
      when scanner.scan("(")                 then :opening_bracket
      when scanner.scan(")")                 then :closing_bracket
      when scanner.scan("{")                 then :opening_brace
      when scanner.scan("}")                 then :closing_brace
      when scanner.scan(":")                 then :colon
      when scanner.scan(";")                 then :semicolon
      else
        super
      end
    end
  end
end
