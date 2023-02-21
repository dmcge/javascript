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
    end
  end
end
