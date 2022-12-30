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
      # FIXME: this isn’t at all correct
      when scanner.scan(/;|\R|\z/) then tokenize_semicolon

      when scanner.scan(/\d/)      then tokenize_number

      # FIXME: a dot isn’t an operator
      when scanner.scan(".")       then tokenize_number_or_operator

      # FIXME: this probably isn’t right
      when scanner.scan("+")       then tokenize_number_or_operator
      when scanner.scan("-")       then tokenize_number_or_operator

      # FIXME: we don’t need all these lines when they all do the same thing
      when scanner.scan("**")      then tokenize_operator
      when scanner.scan("*")       then tokenize_operator
      when scanner.scan("/")       then tokenize_operator
      when scanner.scan(">>>")     then tokenize_operator
      when scanner.scan(">>")      then tokenize_operator
      when scanner.scan("<<")      then tokenize_operator
      when scanner.scan(">=")      then tokenize_operator
      when scanner.scan(">")       then tokenize_operator
      when scanner.scan("<=")      then tokenize_operator
      when scanner.scan("<")       then tokenize_operator
      when scanner.scan("%")       then tokenize_operator
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
        when scanner.scan(/0x/i) then tokenize_nondecimal_number(number, base: 16, pattern: /\h/)
        when scanner.scan(/0b/i) then tokenize_nondecimal_number(number, base: 2)
        when scanner.scan(/0o/i) then tokenize_nondecimal_number(number, base: 8)
        when scanner.scan("0")   then tokenize_potentially_nondecimal_number(number, base: 8)
        else                          tokenize_decimal_number(number)
        end
      end
    end

    def tokenize_nondecimal_number(number, base:, pattern: /[0-#{base - 1}]/)
      digits = ""

      loop do
        case
        when scanner.scan(/[[:alnum:]]/)
          if scanner.matched.match?(pattern)
            digits << scanner.matched
          else
            raise "Syntax error!"
          end
        when scanner.scan("_")
          raise "Syntax error!" unless digits.chars.last&.match?(pattern) && scanner.peek(1).match?(pattern)
        else
          if digits.empty?
            raise "Syntax error!"
          else
            break
          end
        end
      end

      number.digits << digits.to_i(base).to_s
    end

    def tokenize_potentially_nondecimal_number(number, base:)
      scanner.unscan
      tokenize_decimal_number(number)

      if number.type == :integer && number.digits.match?(/^[0-#{base - 1}]+$/)
        number.digits.replace number.digits.to_i(base).to_s
      else
        number
      end
    end

    def tokenize_decimal_number(number)
      loop do
        case
        when scanner.scan(/\d+/)
          number.digits << scanner.matched
        when scanner.scan(/\.\d/)
          if number.type == :integer
            number.type = :decimal
            number.digits << scanner.matched
          else
            raise "Syntax error!"
          end
        when scanner.scan("_")
          raise "Syntax error!" unless number.digits.chars.last&.match?(/\d/) && scanner.peek(1).match?(/\d/)
        when scanner.scan(/e/i)
          if number.type == :exponential
            raise "Syntax error!"
          else
            number.type = :exponential
            number.digits << scanner.matched
          end
        when scanner.scan(/[a-z]/i)
          raise "Syntax error!"
        when scanner.scan(/[+-]/)
          if number.digits.chars.last.casecmp?("e")
            number.digits << scanner.matched
          else
            scanner.unscan
            break
          end
        else
          break
        end
      end
    end

    def tokenize_number_or_operator
      if follows_word_boundary? && scanner.peek(1).match?(/\d/)
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
