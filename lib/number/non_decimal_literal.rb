class Number
  class NonDecimalLiteral < Literal
    attr_reader :base

    def initialize(base:)
      super()
      @base = base
    end

    def value
      digits.join.to_i(base)
    end
  end
end
