module Javascript
  class String < ::String
    def +(other)
      String.new(to_s + other.to_s)
    end

    def truthy?
      !empty?
    end

    def to_number
      numeric = strip

      case
      when numeric.empty?
        Number.new(0)
      when numeric.start_with?("+")
        String.new(delete_prefix("+")).to_number
      when numeric.start_with?("-")
        -String.new(delete_prefix("-")).to_number
      when numeric.match?(/\AInfinity\z/)
        Number.new(Float::INFINITY)
      else
        Number.new(Float(numeric, exception: false) || Integer(numeric, exception: false) || Float::NAN)
      end
    end

    def to_string
      self
    end
  end
end
