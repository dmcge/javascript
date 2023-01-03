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
        -String.new(delete_prefix("-")).to_number
      when numeric.match?(/\AInfinity\z/)
        Number.new(Float::INFINITY)
      when numeric.match?(/\s/)
        Number.new(Float::NAN)
      when number_token = (Tokenizer.new(numeric).consume(:number) rescue nil)
        Number.new(number_token.literal)
      else
        Number.new(Float::NAN)
      end
    end
  end
end
