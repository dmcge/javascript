module Javascript
  class Parser
    class Scoping
      attr_reader :variables

      def initialize
        @variables = Set.new
      end
    end
  end
end
