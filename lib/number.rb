require_relative "number/literal"
require_relative "number/non_decimal_literal"

class Number
  include Comparable

  attr_reader :value

  def initialize(value)
    @value = value.to_f
  end

  def <=>(other) = value <=> other.to_f

  def +(other)  = Number.new(value + other.value)
  def -(other)  = Number.new(value - other.value)
  def *(other)  = Number.new(value * other.value)
  def /(other)  = Number.new(value / other.value)
  def %(other)  = Number.new(value % other.value)
  def **(other) = Number.new(value ** other.value)

  def <<(other)
    Number.new(to_i << (other.unsigned.to_i % 32))
  end

  def >>(other)
    Number.new(to_i >> (other.unsigned.to_i % 32))
  end

  def ==(other)
    value.nan? && other.to_f.nan? || value == other.to_f
  end

  def -@
    Number.new(-value)
  end

  def unsigned
    Number.new(to_f % (2 ** 32))
  end

  def integer?
    to_i == value
  end

  def nan?
    value.nan?
  end

  def infinity?
    value.infinite?
  end

  def to_number
    self
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
end
