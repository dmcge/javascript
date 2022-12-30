class Number
  attr_accessor :type
  attr_reader :digits

  def initialize
    @type = :integer
    @digits = []
  end

  def value
    digits.join.to_f
  end
end
