require "strscan"
require "javascript/tokenizer/grammar"

module Javascript
  class Tokenizer
    Token = Struct.new(:type, :value, :literal, :line_number, :column, keyword_init: true)

    def initialize(javascript)
      @scanner  = StringScanner.new(javascript)
      @grammar  = Grammar.new(scanner)
      @advances = []
    end

    def current_token
      advances.last.tokens.last
    end

    def next_token
      advance
      current_token
    end

    def consume(type)
      token = next_token

      if type === token.type || type == token.value
        token
      else
        rewind
        nil
      end
    end

    def consume_line_break
      if scanner.scan($/)
        tokens << Token.new(type: :line_break, raw: scanner.matched, starting_position: scanner.pos - scanner.matched.bytesize, ending_position: scanner.pos)
      end
    end

    def until(type)
      loop do
        case
        when consume(type)
          break
        when finished?
          raise SyntaxError
        else
          yield
        end
      end
    end

    def look_ahead
      next_token.tap { rewind }
    end

    def rewind
      scanner.pos -= advances.pop.tokens.last.value&.bytesize || 0
    end

    def finished?
      scanner.eos?
    end

    private
      attr_reader :scanner, :advances

      Advance = Struct.new(:tokens)

      def advance
        tokens = []
        tokens << advance_to_next_token
        tokens << advance_to_next_token while [:whitespace, :line_break, :comment].include?(tokens.last.type)

        advances << Advance.new(tokens)
      end

      def advance_to_next_token
        starting_position   = scanner.pos
        type, literal       = @grammar.next_token
        ending_position     = scanner.pos
        value               = scanner.string[starting_position...ending_position] || ""
        line_number, column = new_location(value)

        Token.new(type: type, literal: literal, value: value, line_number: line_number, column: column)
      end

      def new_location(value)
        if (new_lines = Array(value.scan($/))).any?
          [ current_line_number + new_lines.count, 1 + value.lines.last.length ]
        else
          [ current_line_number, current_column + value.length ]
        end
      end

      def current_line_number
        advances.last&.tokens&.last&.line_number || 1
      end

      def current_column
        advances.last&.tokens&.last&.column || 1
      end
  end
end
