module Javascript
  class String < ::String
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
      when numeric.match?(/\s/)
        Number.new(Float::NAN)
      else
        Number.new(Float(numeric, exception: false) || Integer(numeric, exception: false) || Float::NAN)
      end
    end
  end
end
