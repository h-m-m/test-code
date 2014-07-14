require './Square.rb'

module SudokuSolver

  class Board
    attr_reader :size, :block_size, :value
    

    def CheckSize(size)
      Math.sqrt(size).floor == Math.sqrt(size)
    end

    # defaults size: 9, values_hash: nil, squares_array: nil
    # values must be a hash in the form of 
    #  {[x1,y1]=>value1,[x2,y2]=>value2}
    # initial_array must be a two-dimensional array of arrays of Square objects
    #   all arrays must have length == size
    # specifying both a hash and an array will overwrite data in the array using values specified in the hash
    def initialize(args = {})
      @size = 9
      if args.has_key? :size
        CheckSize(args[:size]) or raise ArgumentError, "sudoku boards can only be certain sizes"
        @size = args[:size]
      end

      @block_size = Math.sqrt(@size).floor
      if args.has_key? :squares_array
        @board = args[:squares_array]
      else
        @board = Array.new(size) {Array.new(size) {Square.new(size)} }
      end

      if args.has_key? :values_hash
        args[:values_hash].is_a?(Hash) or raise ArgumentError, "board object only accepts a hash of initial values"
        args[:values_hash].each do |location,value|
          square(*location).value = value
        end
      end
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

    # a flat list of every vaild coordinate pair
    # would probably make more sense to do this by just iterating over size
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
    
    def clone
      new_board_array = Array.new(@size) do |rowindex|
        Array.new(@size) do |columnindex|
          @board[rowindex][columnindex].clone
        end
      end
      new_board = Board.new(size: size, squares_array: new_board_array)
      return new_board
    end
  end
  
end
