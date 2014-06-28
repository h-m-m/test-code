module SudokuSolver

  class SudoBoard
    attr_reader :size, :block_size, :value
    
    class SudoSquare
      attr_reader :value, :size

      def initialize(size, value = nil)
        @size = size
        @value = value
      end

      def value=(new_value)
        new_value > 0 and new_value <= size or raise ArgumentError, "invalid value for sudoku square"
        @value = new_value
      end

      def to_s
        value.nil? ? '*' : value.to_s
      end
      
      def inspect
        value.inspect
      end

    end

    def CheckSize(size)
      Math.sqrt(size).floor == Math.sqrt(size)
    end

    def initialize(init_size = 9)
      CheckSize(init_size) or raise ArgumentError, "sudoku boards can only be certain sizes"
      @size = init_size
      @block_size = Math.sqrt(init_size)
      @board = Array.new(size) {Array.new(size) {SudoSquare.new(size)} }
    end
    
    def row(row_number)
      row_number > 0 and row_number <= size or raise ArgumentError, "this board has only #{size} rows"
      @board[row_number - 1]
    end
    
    def column(column_number)
      column_number > 0 and column_number <= size or raise ArgumentError, "this board has only #{size} columns"
      @board.collect { |row| row[column_number - 1] }
    end
    
    def square(row_index, column_index)
      row_index > 0 and row_index <= size or raise ArgumentError, "this board has only #{size} rows"
      column_index > 0 and column_index <= size or raise ArgumentError, "this board has only #{size} columns"
      @board[row_index - 1][column_index - 1]
    end

    # return a block based on one-indexed coordinates for blocks 
    # for a standard 9x9 board, these would be 9 blocks from (0,0) through (2,2)
    def block(block_row, block_column)
      block_row > 0 and block_row <= block_size or raise ArgumentError
      block_column > 0 and block_column <= block_size or raise ArgumentError

      first_row = (block_row - 1) * block_size + 1
      first_column = (block_column - 1) * block_size + 1
      rows_indexes = (first_row ... first_row + block_size)
      column_indexes = (first_column ... first_column + block_size)

      row_indexes.inject([]) do |result, row|
        result.concat( column_indexes.collect { |column| square(row,column) } )
      end
    end
      
    def pp
      max_char_width = size / 10 + 1
      digit_format = "%" + max_char_width.to_s + "d"
      line_width = (max_char_width + 1) * size + 2 * (block_size - 1)

      (1..size).each do |row_index|

        (1..size).each do |column_index|
          if square(row_index, column_index).value
            print sprintf(digit_format, square(row_index, column_index).value)
          else
            print '*' * max_char_width
          end
          print ' '
          if column_index % size == 0
            puts
          else
            column_index % block_size == 0 and print "| "
          end
        end

        if row_index % block_size == 0 and row_index != size
          puts "-" * line_width
        end
      end
      puts

    end
    
  end
  
end

__END__

require './SudoSolver.rb'
b = SudokuSolver::SudoBoard.new
b.pp
 
bl = SudokuSolver::SudoBoard.new 16
bl.pp

bl.square(3,4).value = 16

bl.pp

