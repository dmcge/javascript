module Javascript
  class Array < Object
    def elements
      properties.values
    end

    def length
      elements.count
    end

    def ==(other)
      elements == other.to_a
    end

    def <<(value)
      self[length] = value
    end

    def to_a
      elements
    end

    def to_ary
      to_a
    end
  end
end
