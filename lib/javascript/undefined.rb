module Javascript
  class Undefined < Type
    def truthy?
      false
    end
    
    def type
      "undefined"
    end
  end
end
