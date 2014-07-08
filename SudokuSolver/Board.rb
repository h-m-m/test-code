require './Square.rb'

module SudokuSolver

  class Board
    attr_reader :size, :block_size, :value
    

    def CheckSize(size)
      Math.sqrt(size).floor == Math.sqrt(size)
    end

    def initialize(init_size = 9, initial_values = nil, board_array = nil)
      CheckSize(init_size) or raise ArgumentError, "sudoku boards can only be certain sizes"
      @size = init_size
      @block_size = Math.sqrt(init_size).floor
      @board = Array.new(size) {Array.new(size) {Square.new(size)} }
      if initial_values
        initial_values.is_a?(Hash) or raise ArgumentError, "board object only accepts a hash of initial values"
        initial_values.each do |location,value|
          square(*location).value = value
        end
      end
    end
    
    #may replace this with an procedure that checks validity
    def board=(array)
      @board = array
    end

    def row(row_number)
      row_number > 0 and row_number <= size or raise ArgumentError, "this board has only #{size} rows"
      @board[row_number - 1]
    end
    
    def column(column_number)
      column_number > 0 and column_number <= size or raise ArgumentError, "this board has only #{size} columns"
      @board.collect { |row| row[column_number - 1] }
    end

    def rows
      @board
    end
      
    def columns
      (1..size).collect { |index| column(index) }
    end

    def coordinate_list
      @board.each_index.inject([]) do |result,row_index|
        result.concat( 
                      @board[row_index].each_index.collect do |column_index|
                        [row_index + 1, column_index + 1]
                      end
                      )
      end
    end
    
    def square(row_index, column_index)
      row_index > 0 and row_index <= size or raise ArgumentError, "this board has only #{size} rows"
      column_index > 0 and column_index <= size or raise ArgumentError, "this board has only #{size} columns"
      @board[row_index - 1][column_index - 1]
    end

    # return a block based on one-indexed coordinates for blocks
    # for a standard 9x9 board, these would be 9 blocks from (0,0) through (2,2)
    def block_around(row, column)
      row > 0 and row <= size or raise ArgumentError
      column > 0 and column <= size or raise ArgumentError

      # todo: make this more legible
      block_row = (row - 1) / block_size
      block_column = (column - 1) / block_size
      first_row = (block_row ) * block_size + 1
      first_column = (block_column ) * block_size + 1
      row_indexes = (first_row ... first_row + block_size)
      column_indexes = (first_column ... first_column + block_size)

      row_indexes.inject([]) do |result, row|
        result.concat(
          column_indexes.collect do |column|
            square(row,column)
          end
        )
      end
    end
    
    def blocks
      result = []
      (1..block_size).each do |row|
        (1..block_size).each do |column|
          result << block_around(row * block_size, column * block_size)
        end
      end
      result
    end

    def inspect
      line_width = (square(1,1).maximum_width_of_to_s + 1) * size + 2 * (block_size - 1)
      result = ""

      (1..size).each do |row_index|

        (1..size).each do |column_index|
          result += ' ' + square(row_index, column_index).to_s
          if column_index % size == 0
            result += "\n"
          else
            column_index % block_size == 0 and result += " |"
          end
        end

        if row_index % block_size == 0 and row_index != size
          result += "-" * line_width + "\n"
        end
      end
      return result
    end
    
    def pp
      puts inspect
    end
    
    def clone
      new_board_array = Array.new(@size) do |rowindex|
        Array.new(@size) do |columnindex|
          @board[rowindex][columnindex].clone
        end
      end
      new_board = Board.new(@size)
      new_board.board = new_board_array
      return new_board
    end
  end
  
end
