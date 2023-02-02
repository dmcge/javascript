module Javascript
  class Grammar
    class NumberConsumer
      def initialize(scanner)
        @scanner = scanner
      end

      def consume_number
        case
        when scanner.scan(/0x/i)     then consume_nondecimal_number(base: 16)
        when scanner.scan(/0b/i)     then consume_nondecimal_number(base: 2)
        when scanner.scan(/0o/i)     then consume_nondecimal_number(base: 8)
        when scanner.scan(/0(?=\d)/) then consume_potentially_nondecimal_number(base: 8)
        else                              consume_decimal_number
        end
      end

      private
        attr_reader :scanner

        def consume_nondecimal_number(base:)
          consume_digits(pattern: /#{Regexp.union((Array("0".."9") + Array("a".."z"))[0...base]).source}/i).to_i(base)
        end

        def consume_potentially_nondecimal_number(base:)
          decimal = consume_decimal_number

          if decimal.to_i == decimal
            Integer(decimal.to_i.to_s, base, exception: false) || decimal
          else
            decimal
          end
        end

        def consume_decimal_number
          if scanner.scan(".")
            whole      = 0
            fractional = consume_digits
          else
            whole      = consume_digits
            fractional = (consume_fractional_digits if scanner.scan(".")) || 0
          end

          exponent = scanner.scan(/e/i) ? consume_signed_digits : 0

          "#{whole}.#{fractional}e#{exponent}".to_f
        end

        def consume_digits(pattern: /\d/)
          [].tap do |digits|
            loop do
              case
              when scanner.scan(pattern)
                digits << scanner.matched
              when scanner.scan("_")
                raise SyntaxError unless digits.last&.match?(pattern) && scanner.peek(1).match?(pattern)
              else
                if digits.none?
                  raise SyntaxError
                else
                  break
                end
              end
            end
          end.join
        end

        def consume_fractional_digits
          consume_digits if scanner.peek(1).force_encoding("ASCII-8BIT").match?(/\d/)
        end

        def consume_signed_digits(pattern: /\d/)
          sign    = scanner.scan(/\+|\-/).to_s
          integer = consume_digits(pattern: pattern)

          sign + integer
        end
    end
  end
end
