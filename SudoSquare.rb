module SudokuSolver
  
  class Square
    attr_reader :value, :size, :possibilities
    
    def initialize(size, value = nil)
      @size = size
      @value = value
      @possibilities = (1..size).to_a
    end
    
    def valid_value?(value)
      value > 0 and value <= size
    end

    def value=(new_value, override = false)
      valid_value?(new_value) or raise ArgumentError, "invalid value for sudoku square"
      unless override or @possibilities.index(new_value) 
        raise RuntimeError
      end
      @possibilities = [new_value]
      @value = new_value
    end
    
    def to_s
      value.nil? ? '*' : value.to_s
    end
    
    def inspect
      value.inspect
    end

    def delete_possibility(value)
      valid_value?(value) or raise ArgumentError, "possibility outside of valid range for this square"
      if @possibilities.length == 1 and @possibilities[0] == value
        raise RuntimeError, "can't delete last possibility"
      end
      
      @possibilities.delete(value)
      if @possibilities.length == 1 
        @value = @possibilities[0] 
      end

    end
  end
end
