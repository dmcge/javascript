require "strscan"
require_relative "number"

Semicolon = Class.new
Dot = Class.new

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

      when scanner.scan(/\d/)      then tokenize_numeric
      when scanner.scan(".")       then tokenize_dot
      when scanner.scan("+")       then tokenize_plus

        # FIXME: we don’t need all these lines when they all do the same thing
      when scanner.scan("-")       then tokenize_operator
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
      Semicolon.new
    end

    def tokenize_numeric
      scanner.unscan
      tokenize_number
    end

    def tokenize_number
      case
      when scanner.scan(/0x/i)     then tokenize_nondecimal_number(base: 16, pattern: /\h/)
      when scanner.scan(/0b/i)     then tokenize_nondecimal_number(base: 2)
      when scanner.scan(/0o/i)     then tokenize_nondecimal_number(base: 8)
      when scanner.scan(/0(?=\d)/) then tokenize_potentially_nondecimal_number(base: 8)
      else                              tokenize_decimal_number
      end
    end

    def tokenize_nondecimal_number(base:, pattern: /[0-#{base - 1}]/)
      Number.new.tap do |number|
        digits = []

        loop do
          case
          when scanner.scan(/[[:alnum:]]/)
            if scanner.matched.match?(pattern)
              digits << scanner.matched
            else
              raise "Syntax error!"
            end
          when scanner.scan("_")
            raise "Syntax error!" unless digits.last&.match?(pattern) && scanner.peek(1).match?(pattern)
          else
            if digits.empty?
              raise "Syntax error!"
            else
              break
            end
          end
        end

        number.digits.concat(digits.join.to_i(base).to_s.chars)
      end
    end

    def tokenize_potentially_nondecimal_number(base:)
      tokenize_decimal_number.tap do |number|
        if number.integer? && number.digits.all? { |digit| digit.match?(/[0-#{base - 1}]/) }
          number.digits.replace(number.digits.join.to_i(base).to_s.chars)
        end
      end
    end

    def tokenize_decimal_number
      Number.new.tap do |number|
        loop do
          case
          when scanner.scan(/\d/)
            number.digits << scanner.matched
          when scanner.scan(".")
            if number.integer? && scanner.peek(1).match?(/\d/)
              number.digits << scanner.matched
            else
              raise "Syntax error!"
            end
          when scanner.scan("_")
            raise "Syntax error!" unless number.digits.last&.match?(/\d/) && scanner.peek(1).match?(/\d/)
          when scanner.scan(/e/i)
            if number.exponential?
              raise "Syntax error!"
            else
              number.digits << scanner.matched
            end
          when scanner.scan(/[a-z]/i)
            raise "Syntax error!"
          when scanner.scan(/[+-]/)
            if number.digits.last.casecmp?("e")
              number.digits << scanner.matched
            elsif number.digits.last == "."
              raise "Syntax error!"
            else
              scanner.unscan
              break
            end
          else
            if number.digits.last == "."
              raise "Syntax error!"
            else
              break
            end
          end
        end
      end
    end

    def tokenize_dot
      if follows_word_boundary? && scanner.peek(1).match?(/\d/)
        tokenize_numeric
      else
        Dot.new
      end
    end

    def tokenize_plus
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
