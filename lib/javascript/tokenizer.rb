require "strscan"
require "javascript/tokenizer/grammar"

module Javascript
  class Tokenizer
    Token = Struct.new(:type, :raw, :literal, :starting_position, :ending_position, keyword_init: true) do
      def value
        raw.strip
      end
    end

    def initialize(javascript)
      @scanner = StringScanner.new(javascript)
      @grammar = Grammar.new(scanner)
      @tokens  = []
    end

    def current_token
      tokens.last
    end

    def next_token
      advance
      current_token
    end

    def consume(type)
      token = next_token

      if type === token.type
        token
      else
        rewind
        nil
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
      scanner.pos = tokens.pop.starting_position
    end

    def finished?
      scanner.eos?
    end

    private
      attr_reader :scanner, :tokens

      def advance
        Token.new.tap do |token|
          token.starting_position   = scanner.pos
          token.type, token.literal = @grammar.next_token
          token.ending_position     = scanner.pos
          token.raw                 = scanner.string[token.starting_position...token.ending_position]

          tokens << token
        end
      end
  end
end
