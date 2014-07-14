module SudokuSolver
  
  class Square
    attr_reader :value, :size, :possibilities
    
    # this should probably be a class method that takes size as an argument
    attr_reader :maximum_width_of_to_s
    
    def initialize(size, init_value = nil)
      @size = size
      if init_value.nil?
        @value = nil
        @possibilities = (1..size).to_a
      else
        (init_value > 0 and init_value <= size) or raise ArgumentError
        @value = init_value
        @possibilities = [init_value]
      end
      @maximum_width_of_to_s = size / 10 + 1
    end
    
    def valid_value?(value)
      value > 0 and value <= size
    end

    def value=(new_value)
      valid_value?(new_value) or raise ArgumentError, "invalid value for sudoku square"
      unless @possibilities.index(new_value) 
        raise RuntimeError, "value #{new_value} not in the list #{@possibilities}"
      end
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
      if @value
        return false
      end
      
      @possibilities.delete(value)
      if @possibilities.length == 1 
        @value = @possibilities[0] 
      end

    end

    def possibilities=(list)
      #may replace this with an procedure that checks validity
      @possibilities = list
    end

    def clone
      new_square = Square.new(@size, @value)
      if @value.nil?
        new_square.possibilities = @possibilities.clone
      end
      return new_square
    end

  end
end
