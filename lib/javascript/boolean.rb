module Javascript
  class Boolean < Type
    class << self
      def wrap(value)
        if value
          True.new
        else
          False.new
        end
      end
    end

    def true?
      raise NotImplementedError
    end

    def truthy?
      true?
    end

    def to_number
      Number.new(to_i)
    end

    def to_boolean
      self
    end

    def to_i
      raise NotImplementedError
    end
  end

  class True < Boolean
    def true?
      true
    end

    def !@
      False.new
    end

    def to_s
      "true"
    end

    def to_i
      1
    end
  end

  class False < Boolean
    def true?
      false
    end

    def !@
      True.new
    end

    def to_s
      "false"
    end

    def to_i
      0
    end
  end
end
