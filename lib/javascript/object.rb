module Javascript
  class Object < Type
    attr_reader :properties

    def initialize
      @properties = {}
    end

    def [](name)
      properties[name.to_s]
    end

    def []=(name, value)
      properties[name.to_s] = value
    end
  end
end
