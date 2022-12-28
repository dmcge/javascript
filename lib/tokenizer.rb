require "strscan"

class Tokenizer
  def initialize(javascript)
    @scanner = StringScanner.new(javascript)
    @tokens  = []
  end

  def current_token
    @tokens.last&.type
  end

  def next_token
    advance
    current_token
  end

  def consume(type)
    token = next_token

    if type === token
      token
    else
      rewind
      nil
    end
  end

  # def consume!(type)
  #   consume(type) or raise
  # end

  def rewind
    scanner.pos = @tokens.pop.starting_position
  end

  def finished?
    scanner.eos?
  end

  private
    Token = Struct.new(:type, :starting_position, :ending_position, keyword_init: true)

    attr_reader :scanner

    def advance
      @tokens << Token.new(starting_position: scanner.pos, type: advance_to_next_token, ending_position: scanner.pos)
    end

    def advance_to_next_token
      skip_whitespace

      case
      when scanner.scan(/[0-9]+/) then tokenize_integer
      when scanner.scan("+")      then tokenize_plus
      when scanner.scan("-")      then tokenize_minus
      when scanner.scan("*")      then tokenize_multiplication
      when scanner.scan("/")      then tokenize_division
      end
    end

    def skip_whitespace
      scanner.skip /\s+/
    end

    def tokenize_integer
      scanner.matched.to_i
    end

    def tokenize_plus
      "+"
    end

    def tokenize_minus
      "-"
    end

    def tokenize_multiplication
      "*"
    end

    def tokenize_division
      "/"
    end
end
