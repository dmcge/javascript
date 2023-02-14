require_relative "interpreter/context"
require_relative "interpreter/environment"

module Javascript
  Reference = Struct.new(:value)

  class Interpreter
    def initialize(script)
      @statement_list = Parser.new(script).parse
      @context = Context.new
    end

    def execute
      execute_statement_list(@statement_list)
    end

    private
      attr_reader :context

      def execute_statement_list(list)
        list.statements.reduce(nil) { |_, statement| execute_statement(statement) }
      end

      def execute_statement(statement)
        case statement
        when VariableStatement   then execute_variable_statement(statement)
        when If                  then execute_if_statement(statement)
        when FunctionDeclaration then execute_function_declaration(statement)
        when Block               then execute_block(statement)
        when Return              then execute_return_statement(statement)
        when ExpressionStatement then execute_expression_statement(statement)
        when StatementList       then execute_statement_list(statement)
        end
      end

      def execute_variable_statement(statement)
        statement.declarations.each { |declaration| execute_variable_declaration(declaration) }
      end

      def execute_variable_declaration(declaration)
        context.environment[declaration.name] = evaluate_expression(declaration.value)
      end

      def execute_if_statement(if_statement)
        if evaluate_value(if_statement.condition).truthy?
          execute_statement(if_statement.consequent)
        elsif if_statement.alternative
          execute_statement(if_statement.alternative)
        end
      end

      def execute_function_declaration(declaration)
        evaluate_expression(declaration.definition)
      end

      def execute_block(block)
        execute_statement(block.body)
      end

      def execute_return_statement(statement)
        throw :return, evaluate_value(statement.expression)
      end

      def execute_expression_statement(statement)
        evaluate_value(statement.expression)
      end


      def evaluate_value(expression)
        evaluate_expression(expression).then do |result|
          if result.is_a?(Reference)
            result.value
          else
            result
          end
        end
      end

      def evaluate_expression(expression)
        case expression
        when FunctionDefinition then evaluate_function_definition(expression)
        when FunctionCall       then evaluate_function_call(expression)
        when Identifier         then evaluate_identifier(expression)
        when Assignment         then evaluate_assignment(expression)
        when StringLiteral      then evaluate_string_literal(expression)
        when NumberLiteral      then evaluate_number_literal(expression)
        when BooleanLiteral     then evaluate_boolean_literal(expression)
        when ObjectLiteral      then evaluate_object_literal(expression)
        when ArrayLiteral       then evaluate_array_literal(expression)
        when PropertyAccess     then evaluate_property_access(expression)
        when UnaryOperation     then evaluate_unary_operation(expression)
        when BinaryOperation    then evaluate_binary_operation(expression)
        when Ternary            then evaluate_ternary(expression)
        end
      end

      def evaluate_function_definition(definition)
        context.environment[definition.name] = Function.new(definition: definition, environment: context.environment)
      end

      def evaluate_function_call(function_call)
        function  = evaluate_value(function_call.callee)
        arguments = function.definition.parameters.zip(function_call.arguments).each_with_object({}) do |(parameter, argument), arguments|
          arguments[parameter.name] = evaluate_value(argument || parameter.default)
        end

        context.in_new_environment(parent: function.environment) do
          arguments.each do |name, value|
            context.environment[name] = value
          end

          # FIXME
          catch :return do
            execute_block(function.definition.body)
            nil
          end
        end
      end

      def evaluate_identifier(identifier)
        context.environment[identifier.name]
      end

      def evaluate_assignment(assignment)
        reference = evaluate_expression(assignment.left_hand_side)

        reference.value = \
          if assignment.operator
            evaluate_binary_operation(assignment)
          else
            evaluate_value(assignment.right_hand_side)
          end
      end

      def evaluate_string_literal(literal)
        String.new(literal.value)
      end

      def evaluate_number_literal(literal)
        Number.new(literal.value)
      end

      def evaluate_boolean_literal(literal)
        Boolean.wrap(literal.value)
      end

      def evaluate_object_literal(literal)
        Object.new.tap do |object|
          literal.properties.each do |property|
            object[property.name] = evaluate_value(property.value)
          end
        end
      end

      def evaluate_array_literal(literal)
        Array.new.tap do |array|
          literal.elements.each { |element| array << evaluate_value(element) }
        end
      end

      def evaluate_property_access(property_access)
        receiver = evaluate_value(property_access.receiver)
        accessor = property_access.computed ? property_access.accessor : evaluate_value(property_access.accessor)

        receiver[accessor] ||= nil
        receiver[accessor]
      end

      def evaluate_unary_operation(operation)
        operator = Operator.for(operation.operator)

        # FIXME
        case operator
        when Operator::Increment, Operator::Decrement
          operator.perform_unary(evaluate_expression(operation.operand), position: operation.position)
        else
          operator.perform_unary(evaluate_value(operation.operand))
        end
      end

      def evaluate_binary_operation(operation)
        # FIXME
        case operation.operator
        when "&&"
          if (left_hand_side = evaluate_value(operation.left_hand_side)).truthy?
            evaluate_value(operation.right_hand_side)
          else
            left_hand_side
          end
        when "||"
          if (left_hand_side = evaluate_value(operation.left_hand_side)).truthy?
            left_hand_side
          else
            evaluate_value(operation.right_hand_side)
          end
        else
          operator        = Operator.for(operation.operator)
          left_hand_side  = evaluate_value(operation.left_hand_side)
          right_hand_side = evaluate_value(operation.right_hand_side)

          operator.perform_binary(left_hand_side, right_hand_side)
        end
      end

      def evaluate_ternary(ternary)
        if evaluate_value(ternary.condition).truthy?
          evaluate_value(ternary.consequent)
        elsif ternary.alternative
          evaluate_value(ternary.alternative)
        end
      end
  end
end
