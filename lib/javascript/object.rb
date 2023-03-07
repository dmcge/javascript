module Javascript
  class Object < Type
    Property = Struct.new(:value)

    attr_reader :properties

    def initialize
      @properties = {}
    end

    def [](name)
      properties[name.to_s]
    end

    def []=(name, value)
      properties[name.to_s] = Property.new(value)
    end

    def type
      "object"
    end
  end
end
