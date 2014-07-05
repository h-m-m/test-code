module SudokuSolver
  
  class Square
    attr_reader :value, :size, :possibilities
    
    # this should probably be a class method that takes size as an argument
    attr_reader :maximum_width_of_to_s
    
    def initialize(size, value = nil)
      @size = size
      @value = value
      @possibilities = (1..size).to_a
      @maximum_width_of_to_s = size / 10 + 1
    end
    
    def valid_value?(value)
      value > 0 and value <= size
    end

    def value=(new_value)
      valid_value?(new_value) or raise ArgumentError, "invalid value for sudoku square"
      @possibilities = [new_value]
      @value = new_value
    end

    def update_value_if_valid(new_value)
      unless @possibilities.index(new_value) 
        return false
      end
      value = new_value
    end

    def to_s
      format_string = '%' + @maximum_width_of_to_s.to_s + 'd'
      value.nil? ? '*' * @maximum_width_of_to_s : sprintf(format_string, value)
    end
    
    def inspect
      value.inspect
    end

    def delete_possibility(value)
      valid_value?(value) or raise ArgumentError, "possibility outside of valid range for this square"
      if @possibilities.length == 1 and @possibilities[0] == value
        return false
      end
      
      @possibilities.delete(value)
      if @possibilities.length == 1 
        @value = @possibilities[0] 
      end

    end
  end
end
