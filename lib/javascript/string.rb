module Javascript
  class String < Type
    include Comparable

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def +(other)
      String.new(to_s + other.to_s)
    end

    def <=>(other)
      value <=> other.to_s
    end

    def truthy?
      !empty?
    end

    def empty?
      value.empty?
    end

    def to_number
      numeric = value.strip

      case
      when numeric.empty?
        Number.new(0)
      when numeric.start_with?("+")
        String.new(numeric.delete_prefix("+")).to_number
      when numeric.start_with?("-")
        -String.new(numeric.delete_prefix("-")).to_number
      when numeric.match?(/\AInfinity\z/)
        Number.new(Float::INFINITY)
      else
        Number.new(Float(numeric, exception: false) || Integer(numeric, exception: false) || Float::NAN)
      end
    end

    def to_string
      self
    end

    def to_s
      value
    end

    def to_str
      to_s
    end
  end
end
