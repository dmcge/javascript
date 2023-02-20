require_relative "interpreter/context"
require_relative "interpreter/environment"

module Javascript
  class Interpreter
    def initialize(script)
      @script  = Parser.new(script).parse
      @context = Context.new
    end

    def execute
      define_vars(@script.vars)
      define_lets(@script.lets)
      define_consts(@script.consts)
      execute_statement(@script.body)
    end

    def evaluate_value(expression)
      evaluate_expression(expression).then do |result|
        case result
        when Environment::Binding, Object::Property
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
      when NullLiteral        then evaluate_null_literal(expression)
      else
        raise "Couldn’t evaluate #{expression.inspect}"
      end
    end

    private
      attr_reader :context

      def define_vars(variables)
        context.environment.define(variables).each(&:initialize)
      end

      def define_lets(variables)
        context.environment.define(variables)
      end

      def define_consts(variables)
        context.environment.define(variables).each { |binding| binding.read_only = true }
      end

      def execute_statement_list(list)
        list.statements.reduce(nil) { |_, statement| execute_statement(statement) }
      end

      def execute_statement(statement)
        case statement
        when VarStatement        then execute_var_statement(statement)
        when LetStatement        then execute_let_or_const_statement(statement)
        when ConstStatement      then execute_let_or_const_statement(statement)
        when If                  then execute_if_statement(statement)
        when FunctionDeclaration then execute_function_declaration(statement)
        when Block               then execute_block(statement)
        when Return              then execute_return_statement(statement)
        when ExpressionStatement then execute_expression_statement(statement)
        when StatementList       then execute_statement_list(statement)
        else
          raise "Couldn’t execute #{statement.inspect}"
        end
      end

      def execute_var_statement(statement)
        statement.declarations.each do |declaration|
          context.environment[declaration.name].value = evaluate_value(declaration.value) if declaration.value
        end
      end

      def execute_let_or_const_statement(statement)
        statement.declarations.each do |declaration|
          context.environment[declaration.name].initialize(declaration.value ? evaluate_value(declaration.value) : nil)
        end
      end

      def execute_if_statement(if_statement)
        if evaluate_value(if_statement.condition).truthy?
          execute_statement(if_statement.consequent)
        elsif if_statement.alternative
          execute_statement(if_statement.alternative)
        end
      end

      def execute_function_declaration(declaration)
        context.environment[declaration.definition.name] = Function.new(definition: declaration.definition, environment: context.environment)
      end

      def execute_block(block)
        context.in_new_environment do
          define_lets(block.lets)
          define_consts(block.consts)
          execute_statement(block.body)
        end
      end

      def execute_return_statement(statement)
        throw :return, statement.expression ? evaluate_value(statement.expression) : nil
      end

      def execute_expression_statement(statement)
        evaluate_value(statement.expression)
      end


      def evaluate_function_definition(definition)
        if definition.name
          evaluate_named_function_definition(definition)
        else
          evaluate_anonymous_function_definition(definition)
        end
      end

      def evaluate_named_function_definition(definition)
        environment = Environment.new(parent: context.environment)
        environment[definition.name] = Function.new(definition: definition, environment: environment)
      end

      def evaluate_anonymous_function_definition(definition)
        Function.new(definition: definition, environment: context.environment)
      end

      def evaluate_function_call(function_call)
        function  = evaluate_value(function_call.callee)

        arguments = function_call.arguments.zip(function.definition.parameters).each_with_object({}) do |(argument, parameter), arguments|
          arguments[parameter.name] = evaluate_value(argument)
        end

        context.in_new_environment(parent: function.environment) do
          define_vars(function.definition.vars)
          define_lets(function.definition.lets)
          define_consts(function.definition.consts)

          function.definition.parameters.each do |parameter|
            context.environment[parameter.name] = arguments[parameter.name] || (evaluate_value(parameter.default) if parameter.default)
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
          literal.elements.each { |element| array << (element ? evaluate_value(element) : nil) }
        end
      end

      def evaluate_property_access(property_access)
        receiver = evaluate_value(property_access.receiver)
        accessor = property_access.computed ? property_access.accessor : evaluate_value(property_access.accessor)

        receiver[accessor] ||= nil
        receiver[accessor]
      end

      def evaluate_unary_operation(operation)
        Operator.for(operation.operator, interpreter: self).unary(operation)
      end

      def evaluate_binary_operation(operation)
        Operator.for(operation.operator, interpreter: self).binary(operation)
      end

      def evaluate_ternary(ternary)
        if evaluate_value(ternary.condition).truthy?
          evaluate_value(ternary.consequent)
        elsif ternary.alternative
          evaluate_value(ternary.alternative)
        end
      end

      # TODO
      def evaluate_null_literal(null)
        nil
      end
  end
end
