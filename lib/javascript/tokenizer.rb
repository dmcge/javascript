require "strscan"

module Javascript
  class Tokenizer
    Token = Struct.new(:type, :raw, :literal, :starting_position, :ending_position, keyword_init: true) do
      def value
        raw&.strip
      end
    end

    def initialize(javascript)
      @scanner  = StringScanner.new(javascript)
      @grammar  = Grammar.new(scanner)
      @advances = []
    end

    def grammar
      @grammar.class
    end

    def grammar=(grammar)
      @grammar = grammar.new(scanner)
    end

    def with_grammar(grammar)
      previous_grammar = self.grammar
      self.grammar = grammar
      yield
    ensure
      self.grammar = previous_grammar
    end

    def current_token
      advances.last.tokens.last
    end

    def next_token
      advance
      current_token
    end

    def consume(types)
      advance(keep_line_breaks: Array(types).include?(:line_break))

      if Array(types).detect { |type| type === current_token.type || type == current_token.value }
        current_token
      else
        rewind
        nil
      end
    end

    def consume!(type)
      consume(type) or raise SyntaxError
    end

    def peek(type)
      if consume(type)
        rewind
        true
      else
        false
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

    def insert_semicolon
      scanner.string[scanner.charpos] = ";" + scanner.string[scanner.charpos]
    end

    def look_ahead
      next_token.tap { rewind }
    end

    def rewind
      scanner.pos = advances.pop.tokens.first.starting_position
    end

    def finished?
      consume(:end_of_file) || scanner.eos?
    end

    private
      attr_reader :scanner, :advances

      Advance = Struct.new(:tokens)

      def advance(keep_line_breaks: false)
        tokens = []
        tokens << advance_to_next_token
        tokens << advance_to_next_token while [(:line_break unless keep_line_breaks)].include?(tokens.last.type)

        advances << Advance.new(tokens)
      end

      def advance_to_next_token
        @grammar.skip_comments

        Token.new.tap do |token|
          token.starting_position   = scanner.pos
          token.type, token.literal = @grammar.next_token
          token.ending_position     = scanner.pos
          token.raw                 = scanner.string.byteslice(token.starting_position...token.ending_position)
        end
      end
  end
end
