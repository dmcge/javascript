class Number
  attr_reader :digits

  def initialize
    @type = :integer
    @digits = []
  end

  def value
    digits.join.to_f
  end

  def integer?
    !digits.include?(".")
  end

  def exponential?
    digits.include?("e")
  end
end
