class ArithmeticOperation
  attr_reader :operator, :left_hand_side, :right_hand_side

  def initialize(operator, left_hand_side, right_hand_side)
    if left_hand_side.is_a?(ArithmeticOperation) && precedence_of(operator) > precedence_of(left_hand_side.operator)
      @operator        = left_hand_side.operator
      @left_hand_side  = left_hand_side.left_hand_side
      @right_hand_side = ArithmeticOperation.new(operator, left_hand_side.right_hand_side, right_hand_side)
    else
      @operator        = operator
      @left_hand_side  = left_hand_side
      @right_hand_side = right_hand_side
    end
  end

  private
    OPERATOR_PRECEDENCE = { "**" => 3, "/" => 2, "*" => 2, "+" => 1, "-" => 1 }

    def precedence_of(operator)
      OPERATOR_PRECEDENCE[operator]
    end
end
