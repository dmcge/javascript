module Javascript
  class Null < Type
    def truthy?
      false
    end
    
    def type
      "object"
    end
  end
end
