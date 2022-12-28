require "strscan"

class Number
  attr_accessor :type
  attr_reader :digits

  def initialize
    @type = :integer
    @digits = ""
  end

  def value
    BigDecimal(digits)
  end
end

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

  def rewind
    scanner.pos = tokens.pop.starting_position
  end

  def finished?
    scanner.eos?
  end

  private
    Token = Struct.new(:type, :starting_position, :ending_position, keyword_init: true)

    attr_reader :scanner, :tokens

    def advance
      tokens << Token.new(starting_position: scanner.pos, type: advance_to_next_token, ending_position: scanner.pos)
    end

    def advance_to_next_token
      skip_whitespace

      case
      when scanner.scan(/[0-9]/)  then tokenize_number
      when scanner.scan(".")      then tokenize_dot
      when scanner.scan("+")      then tokenize_plus
      when scanner.scan("-")      then tokenize_minus
      when scanner.scan("*")      then tokenize_multiplication
      when scanner.scan("/")      then tokenize_division
      end
    end

    def skip_whitespace
      scanner.skip /\s+/
    end

    def tokenize_number
      scanner.unscan

      Number.new.tap do |number|
        if scanner.scan(/\-|\+/)
          number.digits << scanner.matched
        end

        loop do
          case
          when scanner.scan(/[[:digit:]]+/)
            number.digits << scanner.matched
          when scanner.scan(/\.[[:digit:]]/)
            if number.type == :integer
              number.type = :decimal
              number.digits << scanner.matched
            else
              raise "Parse error!"
            end
          when scanner.scan("_")
            raise "Parse error!" unless scanner.peek(1).match?(/[[:digit:]]/)
          when scanner.scan(/e/i)
            if number.type == :exponential
              raise "Parse error!"
            else
              number.digits << scanner.matched
            end
          else
            break
          end
        end
      end
    end

    def tokenize_dot
      if follows_word_boundary? && scanner.peek(1).match?(/[[:digit:]]/)
        tokenize_number
      else
        "."
      end
    end

    def tokenize_plus
      if follows_word_boundary? && scanner.peek(1).match?(/[[:digit:]]/)
        tokenize_number
      else
        "+"
      end
    end

    def tokenize_minus
      if follows_word_boundary? && scanner.peek(1).match?(/[[:digit:]]/)
        tokenize_number
      else
        "-"
      end
    end

    def tokenize_multiplication
      "*"
    end

    def tokenize_division
      "/"
    end


    def follows_word_boundary?
      tokens.last&.ending_position != scanner.pos - 1
    end
end
