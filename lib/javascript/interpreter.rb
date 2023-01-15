module Javascript
  class Interpreter
    def initialize(script)
      @statement_list = Parser.new(script).parse
      @identifiers    = {} # FIXME
    end

    def execute
      execute_statement_list(@statement_list)
    end

    private
      def execute_statement_list(list)
        result = execute_statement(list.statements.shift) until list.statements.empty?
        result
      end

      def execute_statement(statement)
        case statement
        when VariableStatement   then execute_variable_statement(statement)
        when If                  then execute_if_statement(statement)
        when Block               then execute_block(statement)
        when Return              then execute_return(statement)
        when ExpressionStatement then execute_expression_statement(statement)
        when StatementList       then execute_statement_list(statement)
        end
      end

      def execute_variable_statement(statement)
        statement.declarations.each { |declaration| execute_variable_declaration(declaration) }
      end

      def execute_variable_declaration(declaration)
        @identifiers[declaration.name] = evaluate_expression(declaration.value)
      end

      def execute_if_statement(if_statement)
        if evaluate_expression(if_statement.condition).truthy?
          execute_statement(if_statement.consequent)
        elsif if_statement.alternative
          execute_statement(if_statement.alternative)
        end
      end

      def execute_block(block)
        execute_statement(block.body)
      end

      def execute_return(statement)
        throw :return, evaluate_expression(statement.expression)
      end

      def execute_expression_statement(statement)
        evaluate_expression(statement.expression)
      end

      def evaluate_expression(expression)
        case expression
        when FunctionDefinition then evaluate_function_definition(expression)
        when FunctionCall       then evaluate_function_call(expression)
        when Reference          then evaluate_reference(expression)
        when String             then evaluate_string(expression)
        when Number             then evaluate_number(expression)
        when Boolean            then evaluate_boolean(expression)
        when UnaryOperation     then evaluate_unary_operation(expression)
        when BinaryOperation    then evaluate_binary_operation(expression)
        when Parenthetical      then evaluate_parenthetical(expression)
        end
      end

      def evaluate_function_definition(definition)
        @identifiers[definition.name] = definition
      end

      def evaluate_function_call(function_call)
        function = evaluate_expression(function_call.callee)
        previous_identifiers = @identifiers.dup

        arguments = function.parameters.zip(function_call.arguments).map do |parameter, argument|
          @identifiers[parameter] = evaluate_expression(argument) if argument
        end

        catch :return do
          execute_block(function.body)
          nil
        end
      ensure
        @identifiers = previous_identifiers
      end

      def evaluate_reference(reference)
        @identifiers[reference.name]
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
