class Boolean
  class << self
    def wrap(value)
      if value
        True.new
      else
        False.new
      end
    end
  end

  def true?
    raise NotImplementedError
  end

  def to_number
    Number.new(to_i)
  end
end

class True < Boolean
  def true?
    true
  end

  def to_i
    1
  end
end

class False < Boolean
  def true?
    false
  end

  def to_i
    0
  end
end
