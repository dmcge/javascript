require_relative "operation/operator"

class Operation
  attr_reader :operator, :left_hand_side, :right_hand_side

  def initialize(operator, left_hand_side, right_hand_side)
    if left_hand_side.is_a?(Operation) && operator.precedence > left_hand_side.operator.precedence
      @operator        = left_hand_side.operator
      @left_hand_side  = left_hand_side.left_hand_side
      @right_hand_side = Operation.new(operator, left_hand_side.right_hand_side, right_hand_side)
    else
      @operator        = operator
      @left_hand_side  = left_hand_side
      @right_hand_side = right_hand_side
    end
  end
end
