require "strscan"
require_relative "number"

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
      skip_comments

      case
      when scanner.scan(/;|\R|\z/)     then tokenize_semicolon
      when scanner.scan(/[[:digit:]]/) then tokenize_number
      when scanner.scan(".")           then tokenize_number_or_operator
      when scanner.scan("+")           then tokenize_number_or_operator
      when scanner.scan("-")           then tokenize_number_or_operator
      when scanner.scan("**")          then tokenize_operator
      when scanner.scan("*")           then tokenize_operator
      when scanner.scan("/")           then tokenize_operator
      when scanner.scan(">=")          then tokenize_operator
      when scanner.scan(">")           then tokenize_operator
      when scanner.scan("<=")          then tokenize_operator
      when scanner.scan("<")           then tokenize_operator
      when scanner.scan("%")           then tokenize_operator
      else
        raise "Unrecognised character: #{scanner.getch.inspect}"
      end
    end


    def skip_whitespace
      scanner.skip(/[[:blank:]]+/)
    end

    def skip_comments
      case
      when scanner.scan("//") then skip_single_line_comment
      when scanner.scan("/*") then skip_multiline_comment
      end
    end

    def skip_single_line_comment
      scanner.skip_until(/(?=\R)|\Z/)
    end

    def skip_multiline_comment
      if comment = scanner.scan_until(/\*\//)
        insert_line_break if comment.match?(/\R/)
      else
        raise "Syntax error!"
      end
    end

    def insert_line_break
      scanner.string[scanner.pos] = "\n" + scanner.string[scanner.pos]
    end


    def tokenize_semicolon
      ";"
    end

    def tokenize_number
      scanner.unscan

      Number.new.tap do |number|
        if scanner.scan(/\-|\+/)
          number.digits << scanner.matched
        end

        case
        when scanner.scan(/0b/i) then tokenize_binary_number(number)
        when scanner.scan(/0o/i) then tokenize_octal_number(number)
        else                          tokenize_decimal_number(number)
        end
      end
    end

    def tokenize_binary_number(number)
      digits = ""

      loop do
        case
        when scanner.scan(/[[:digit:]]/)
          if scanner.matched.match?(/0|1/)
            digits << scanner.matched.to_i(2).to_s
          else
            raise "Syntax error!"
          end
        when scanner.scan("_")
          raise "Syntax error!" unless scanner.peek(1).match?(/0|1/)
        else
          break
        end
      end

      if digits.empty?
        raise "Syntax error!"
      else
        number.digits << digits.to_i(2).to_s
      end
    end

    def tokenize_octal_number(number)
      digits = ""

      loop do
        case
        when scanner.scan(/[[:digit:]]/)
          if scanner.matched.match?(/[0-7]/)
            digits << scanner.matched.to_i(8).to_s
          else
            raise "Syntax error!"
          end
        when scanner.scan("_")
          raise "Syntax error!" unless scanner.peek(1).match?(/[0-7]/)
        else
          break
        end
      end

      if digits.empty?
        raise "Syntax error!"
      else
        number.digits << digits.to_i(8).to_s
      end
    end

    def tokenize_decimal_number(number)
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

    def tokenize_number_or_operator
      if follows_word_boundary? && scanner.peek(1).match?(/[[:digit:]]/)
        tokenize_number
      else
        tokenize_operator
      end
    end

    def tokenize_operator
      Operation::Operator.new(scanner.matched)
    end


    def follows_word_boundary?
      tokens.last&.ending_position != scanner.pos - 1
    end
end
