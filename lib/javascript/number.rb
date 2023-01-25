module Javascript
  class Number
    def initialize(value)
      @value = value.to_f
    end

    def +(other)  = Number.new(value + other.value)
    def -(other)  = Number.new(value - other.value)
    def *(other)  = Number.new(value * other.value)
    def /(other)  = Number.new(value / other.value)
    def %(other)  = Number.new(value % other.value)
    def **(other) = Number.new(value ** other.value)

    def <=>(other) = value <=> other.to_f
    def ==(other)  = (self <=> other)&.zero?
    def <(other)   = (self <=> other)&.negative?
    def >(other)   = (self <=> other)&.positive?
    def <=(other)  = self < other || self == other
    def >=(other)  = self > other || self == other

    def <<(other)
      Number.new(Number.new(to_i32 << other.to_ui32 % 32).to_i32)
    end

    def >>(other)
      Number.new(Number.new(to_i32 >> other.to_ui32 % 32).to_i32)
    end

    def -@
      Number.new(-value)
    end

    def unsigned
      Number.new(to_ui32).tap do |number|
        number.define_singleton_method(:to_i32) { number.to_ui32 }
      end
    end

    def integer?
      to_i == value
    end

    def zero?
      value.zero?
    end

    def nan?
      value.nan?
    end

    def infinity?
      value.infinite?
    end

    def truthy?
      !zero?
    end

    def to_string
      String.new(to_s)
    end

    def to_number
      self
    end

    def to_boolean
      Boolean.wrap(truthy?)
    end

    def to_s
      if integer?
        value.to_i.to_s
      else
        value.to_s
      end
    end

    def to_i
      if nan? || infinity?
        0
      else
        value.to_i
      end
    end

    def to_f
      value
    end

    protected
      attr_reader :value

      def to_i32
        [to_i].pack("l").unpack1("l")
      end

      def to_ui32
        [to_i].pack("L").unpack1("L")
      end
  end
end
