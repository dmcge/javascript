class Operation
  class Operator
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def precedence
      case value
      when "**"                 then 4
      when "/", "*", "%"        then 3
      when "+", "-"             then 2
      when "<", "<=", ">", ">=" then 1
      end
    end
  end
end
