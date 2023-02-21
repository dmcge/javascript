module Javascript
  class Parser
    class Scope
      attr_reader :vars, :lets, :consts

      def initialize(vars: Set.new, lets: Set.new, consts: Set.new)
        @vars, @lets, @consts = vars, lets, consts
      end

      def include?(name)
        var?(name) || let?(name) || const?(name)
      end

      def var?(name)
        vars.include?(name)
      end

      def let?(name)
        lets.include?(name)
      end

      def const?(name)
        consts.include?(name)
      end


      def define_within(environment, except: nil)
        define_vars(environment: environment)   unless except == :vars
        define_lets(environment: environment)   unless except == :lets
        define_consts(environment: environment) unless except == :consts
      end

      private
        def define_vars(environment:)
          environment.define(vars).each(&:initialize)
        end

        def define_lets(environment:)
          environment.define(lets)
        end

        def define_consts(environment:)
          environment.define(consts).each { |binding| binding.read_only = true }
        end
    end
  end
end
