class Number
  attr_accessor :type
  attr_reader :digits

  def initialize
    @type = :integer
    @digits = ""
  end

  def value
    digits.to_f
  end
end
