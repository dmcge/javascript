require "strscan"
require "javascript/tokenizer/grammar"

module Javascript
  class Tokenizer
    Token = Struct.new(:type, :value, :literal, :starting_position, :ending_position, keyword_init: true)

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
      scanner.pos = advances.pop.tokens.last.starting_position
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
        Token.new.tap do |token|
          token.starting_position   = scanner.pos
          token.type, token.literal = @grammar.next_token
          token.ending_position     = scanner.pos
          token.value               = scanner.string[token.starting_position...token.ending_position]
        end
      end
  end
end
