module Javascript
  class String < ::String
    def to_number
      numeric = strip

      case
      when numeric.empty?
        Number.new(0)
      when numeric.start_with?("+")
        String.new(delete_prefix("+")).to_number
      when numeric.start_with?("-")
        String.new(delete_prefix("-")).to_number * -1
      when numeric.match?(/\AInfinity\z/)
        Number.new(Float::INFINITY)
      when numeric.match?(/\s/)
        Number.new(Float::NAN)
      when number_token = (Tokenizer.new(numeric).consume(Number) rescue nil)
        number_token
      else
        Number.new(Float::NAN)
      end
    end
  end
end
