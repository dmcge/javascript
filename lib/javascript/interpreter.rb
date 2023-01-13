module Javascript
  class Interpreter
    def initialize(script)
      @statements = Parser.new(script).parse
      @variables  = {} # FIXME
      @functions  = {} # FIXME
    end

    def evaluate
      result = nil
      @statements.each { |statement| result = evaluate_statement(statement) }
      result
    end

    private
      def evaluate_statement(statement)
        case statement
        when VariableStatement   then evaluate_variable_statement(statement)
        when If                  then evaluate_if_statement(statement)
        when Block               then evaluate_block(statement)
        when ExpressionStatement then evaluate_expression_statement(statement)
        end
      end

      def evaluate_variable_statement(statement)
        statement.declarations.each { |declaration| evaluate_variable_declaration(declaration) }
      end

      def evaluate_variable_declaration(declaration)
        @variables[declaration.name] = evaluate_expression(declaration.value)
      end

      def evaluate_expression_statement(statement)
        evaluate_expression(statement.expression)
      end

      def evaluate_expression(expression)
        case expression
        when FunctionDefinition then evaluate_function_definition(expression)
        when FunctionCall       then evaluate_function_call(expression)
        when VariableReference  then evaluate_variable_reference(expression)
        when String             then evaluate_string(expression)
        when Number             then evaluate_number(expression)
        when Boolean            then evaluate_boolean(expression)
        when UnaryOperation     then evaluate_unary_operation(expression)
        when BinaryOperation    then evaluate_binary_operation(expression)
        when Parenthetical      then evaluate_parenthetical(expression)
        end
      end

      def evaluate_function_definition(definition)
        @functions[definition.name] = definition
      end

      def evaluate_function_call(function_call)
        function = @functions[function_call.name]

        previous_variables = @variables.dup

        arguments = function.parameters.zip(function_call.arguments).map do |parameter, argument|
          @variables[parameter] = evaluate_expression(argument) if argument
        end

        evaluate_block(function.body)
      ensure
        @variables = previous_variables
      end

      def evaluate_variable_reference(reference)
        @variables[reference.name]
      end

      def evaluate_string(string)
        string
      end

      def evaluate_number(number)
        number
      end

      def evaluate_boolean(boolean)
        boolean
      end

      def evaluate_if_statement(if_statement)
        if evaluate_expression(if_statement.condition).truthy?
          evaluate_statement(if_statement.consequent)
        elsif if_statement.alternative
          evaluate_statement(if_statement.alternative)
        end
      end

      def evaluate_block(block)
        result = evaluate_statement(block.statements.shift) until block.statements.empty?
        result
      end

      def evaluate_unary_operation(operation)
        operation.operator.perform_unary(evaluate_expression(operation.operand))
      end

      def evaluate_binary_operation(operation)
        left_hand_side  = evaluate_expression(operation.left_hand_side)
        right_hand_side = evaluate_expression(operation.right_hand_side)

        operation.operator.perform_binary(left_hand_side, right_hand_side)
      end

      def evaluate_parenthetical(parenthetical)
        evaluate_expression(parenthetical.expression)
      end
  end
end
