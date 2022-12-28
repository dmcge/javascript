class Number
  attr_accessor :type
  attr_reader :digits

  def initialize
    @type = :integer
    @digits = ""
  end

  def value
    BigDecimal(digits)
  end
end
