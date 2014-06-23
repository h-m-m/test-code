module SudokuSolver
  
  class SudoBoard
    
    class SolvingError < StandardError
    end

    class SudoSquare
      attr_accessor :value, :possibilities
      
      def initialize
        @possibilities = [1,2,3,4,5,6,7,8,9]
        @value = nil
      end
      
      def clone
        copy = super
        copy
      end

      def delete_possibility(number)
        test_value(number)
        return if @possibilities == [number]
        @possibilities.delete(number)
        @value = @possibilities[0] if @possibilities.length == 1
      end
      
      def set_possibility(number)
        test_value(number)
        @possibilities = [number]
        @value = number
      end
      
      def test_value(number)
        number.is_a?(Fixnum)
        number > 0 and number < 10 or raise ArguemntError, "standard sudoku only uses numbers from 1 through 9"
      end
      
      def to_s
        @value.to_s
      end
      
      def inspect
        if @value.nil?
          return "Possibly #{@possibilities}" 
        else
          return @value
        end
      end
      
    end

    def initialize(array = nil)
      if valid_board_array?(array)
        @board = array
      else
        @board ||= Array.new(9) { Array.new(9) {SudoSquare.new}}
      end
    end

    def valid_board_array?(board = nil)
      board ||= @board
      board.is_a?(Array) or return false

      valid_rows = 0
      board.each do |row|

        row.is_a?(Array) or return false

        valid_squares = 0
        row.each do |square|
          square.is_a?(SudoSquare) or return false
          valid_squares += 1
        end
        valid_squares == 9 or return false
        
        valid_rows += 1
      end
      valid_rows == 9 or return false

      return true
    end

    def update_square_without_solve(row, column, value)
      row < 9 or raise ArgumentError, "there are only 9 rows on a Sudoku board"
      column < 9 or raise ArgumentError, "there are only 9 columns on a Sudoku board"
      @board[row][column].set_possibility(value)
    end

    def update(row, column, value)
      puts "update #{row},#{column},#{value}"
      update_square_without_solve(row, column, value)
      solve(false)
    end
    
    def solve(try_guesses = true, last_solution = 9 * 9)
      puts "solve"
      unsolved_count = 9 * 9
      (0..8).each do |row|
        (0..8).each do |column|
          unless @board[row][column].value.nil?
            delete_possibility_from_row(row, @board[row][column].value)
            delete_possibility_from_column(column, @board[row][column].value)
            delete_possibility_from_block(row/3, column/3, @board[row][column].value)
            unsolved_count -= 1 if @board[row][column].value 
          end
        end
      end

      puts "unsolved #{unsolved_count}"
      if unsolved_count
        reduce_rows
        reduce_columns
        reduce_blocks
      end

      return solve(try_guesses, unsolved_count) if unsolved_count != last_solution
      return guess(unsolved_count) if try_guesses && unsolved_count > 0
      pp
      return unsolved_count
    end
    
    def guess(return_value = 81)
      row, column = [nil,nil]
      row, column = coords_of_square_with_two_options
      row, column = first_unsolved_square unless row
      raise SolvingError, "asked to guess on a solved board" unless row
      puts "guessing for #{row},#{column}"
      test_boards = []
      @board[row][column].possibilities.each do |possibility|
        puts "guessing value #{possibility}"
        test_boards.push(b.clone)
        begin
          return_value = test_boards[-1].update(row,column,possibility)
          puts "result of guessing #{possibility} for #{row},#{column}"
          test_boards[-1].pp
          self.pp
        rescue SolvingError => ex
          test_boards.pop
        end
      end
      if test_boards.length == 1 
        @board = test_boards[0].to_a
        pp
      end
      return return_value
    end
    
    def coords_of_square_with_two_options
      (0..8).each do |row|
        (0..8).each do |column|
          @board[row][column].possibilities.length == 2 and return [row,column]
        end
      end
    end
    
    def first_unsolved_square
      (0..8).each do |row|
        (0..8).each do |column|
          @board[row][column].possibilities.length > 1 and return [row,column]
        end
      end
    end

    def delete_possibility_from_row(row, value)
      row < 9 or raise ArgumentError, "there are only 9 rows on a Sudoku board"
      (0..8).each do |column|
        @board[row][column].delete_possibility(value)
      end
    end
    
    def delete_possibility_from_column(column, value)
      column < 9 or raise ArgumentError, "there are only 9 rows on a Sudoku board"
      (0..8).each do |row|
        @board[row][column].delete_possibility(value)
      end
    end
    
    def delete_possibility_from_block(block_row, block_column, value)
      block_row < 3 or raise ArgumentError, "a standard sudoku board has 9 blocks"
      block_column < 3 or raise ArgumentError, "a standard sudoku board has 9 blocks"
      
      (0..2).each do |row_index|
        (0..2).each do |column_index|
          @board[block_row * 3 + row_index][block_column * 3 + column_index].delete_possibility(value)
        end
      end
    end
    
    def reduce_rows
      (0..8).each do |row|
        accumulator = Array.new(9) {Array.new}
        (0..8).each do |column|
          @board[row][column].possibilities.each do |value|
            accumulator[value - 1] << [row,column]
          end
        end

        (0..8).each do |value|
          raise SolvingError if accumulator[value].length == 0
          if accumulator[value].length == 1
            update_square_without_solve(accumulator[value][0][0],accumulator[value][0][1],value + 1)
          end
        end
      end
    end

    def reduce_columns
      (0..8).each do |column|
        accumulator = Array.new(9) {Array.new}
        (0..8).each do |row|
          @board[row][column].possibilities.each do |value|
            accumulator[value - 1] << [row,column]
          end
        end

        (0..8).each do |value|
          raise SolvingError if accumulator[value].length == 0
          if accumulator[value].length == 1
            update_square_without_solve(accumulator[value][0][0],accumulator[value][0][1],value + 1)
          end
        end
      end
    end

    def reduce_blocks
      (0..2).each do |blockrow|
        (0..2).each do |blockcolumn|
          puts "reducing block #{blockrow},#{blockcolumn}"
          accumulator = Array.new(9) {Array.new}
          (0..2).each do |subrow|
            (0..2).each do |subcolumn|
              @board[blockrow * 3 + subrow][blockcolumn * 3 + subcolumn].possibilities.each do |value|
                accumulator[value - 1] << 
                  [blockrow * 3 + subrow,blockcolumn * 3 + subcolumn]
              end
            end
          end
          
          (0..8).each do |value|
            raise SolvingError, "too few possibilities for #{value}" if accumulator[value].length == 0
            if accumulator[value].length == 1
              update_square_without_solve(accumulator[value][0][0],accumulator[value][0][1],value + 1)
            end
          end

        end
      end

    end
    
    def to_a
      @board
    end
    
    def pp
      (0..8).each do |row|
        if row == 3 or row == 6
          puts "------------------------" 
        end
        (0..8).each do |column|
          print " | " if column == 3 or column == 6
          print @board[row][column].value
          @board[row][column].value.nil? and print "*"
          print " "
        end
          puts
      end
      puts
    end

  end # class SudoBoard
  
end


__END__

  b = HMMSudoku::SudoBoard.new
  b.update(0,1,8)
  b.update(0,2,9)
  b.update(0,7,6)
  b.update(1,0,4)
  b.update(1,4,1)
  b.update(1,8,7)
  b.update(2,3,9)
  b.update(2,7,5)
  b.update(3,1,4)
  b.update(3,3,7)
  b.update(3,6,6)
  b.update(4,0,7)
  b.update(4,8,8)
  b.update(5,2,5)
  b.update(5,5,6)
  b.update(5,7,7)
  b.update(6,1,3)
  b.update(6,5,4)
  b.update(7,0,1)
  b.update(7,4,7)
  b.update(7,8,2)
  b.update(8,1,2)
  b.update(8,6,9)
  b.update(8,7,3)
