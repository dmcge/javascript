module Javascript
  ArrayLiteral        = Struct.new(:elements)
  Assignment          = Struct.new(:identifier, :value)
  BinaryOperation     = Struct.new(:operator, :left_hand_side, :right_hand_side)
  Block               = Struct.new(:body)
  BooleanLiteral      = Struct.new(:value, keyword_init: true)
  ExpressionStatement = Struct.new(:expression)
  FunctionCall        = Struct.new(:callee, :arguments)
  FunctionDefinition  = Struct.new(:name, :parameters, :body)
  Identifier          = Struct.new(:name)
  If                  = Struct.new(:condition, :consequent, :alternative)
  NumberLiteral       = Struct.new(:value)
  NullLiteral         = Struct.new(nil)
  ObjectLiteral       = Struct.new(:properties)
  Parenthetical       = Struct.new(:expression)
  PropertyAccess      = Struct.new(:receiver, :accessor, :computed)
  PropertyDefinition  = Struct.new(:name, :value, keyword_init: true)
  Return              = Struct.new(:expression)
  StatementList       = Struct.new(:statements)
  StringLiteral       = Struct.new(:value)
  UnaryOperation      = Struct.new(:operator, :operand, :position)
  VariableDeclaration = Struct.new(:name, :value)
  VariableStatement   = Struct.new(:declarations, keyword_init: true)
end
