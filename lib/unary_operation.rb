require_relative "operation/operator"

class UnaryOperation
  attr_reader :operator, :operand

  def initialize(operator, operand)
    @operator, @operand = operator, operand
  end
end
