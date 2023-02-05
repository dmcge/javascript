module Javascript
  class Array < Object
    def elements
      properties.values
    end

    def length
      elements.count
    end

    def ==(other)
      to_a == other.to_a
    end

    def <<(value)
      self[length] = value
    end

    def to_number
      Number.new(0)
    end

    def to_a
      elements.map(&:value)
    end

    def to_ary
      to_a
    end
  end
end
