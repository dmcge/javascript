module Javascript
  class Type
    def truthy?
      true
    end

    def type
      raise NotImplementedError
    end

    def to_string
      String.new(to_s)
    end

    def to_boolean
      Boolean.wrap(truthy?)
    end

    def to_s
      raise NotImplementedError
    end
  end
end
