module Javascript
  class Function < Type
    attr_reader :definition, :environment

    def initialize(definition:, environment:)
      @definition, @environment = definition, environment
    end

    def type
      "function"
    end
  end
end
