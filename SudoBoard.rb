module SudokuSolver
  
  class SudoBoard
    
	SIZE = 9
	WHOLE_BOARD_SIZE = SIZE * SIZE
	SMALL_BLOCK_SIZE = 3 # or Math.sqrt(SIZE).floor 
	
    class SolvingError < StandardError
    end

    class SudoSquare
      attr_accessor :value, :possibilities
      
      def initialize
        @possibilities = (1..SIZE).to_a
        @value = nil
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
        number > 0 and number <= SIZE or raise ArguemntError, "sudoku only uses numbers from 1 through #{SIZE}"
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
        @board ||= Array.new( WHOLE_BOARD_SIZE )
      end
    end
	
	def valid_board_array?(board)
      board.is_a?(Array) or return false
	  board.lenth == WHOLE_BOARD_SIZE or return false
	  board.index { |entry| not entry.is_a?(SudoSquare) } or return true
    end
	
	def update(value,position)	  
      @board[position].set_possibility(value)
    end
	
    def update_and_solve(value, position1, position2 = nil)
	  if position2
	    position1 < WHOLE_BOARD_SIZE or raise ArgumentError, "there are only #{WHOLE_BOARD_SIZE} rows on the Sudoku board"
	    update_square_without_solve(value, position1)
	  else
	    row < SIZE or raise ArgumentError, "there are only #{SIZE} rows on the Sudoku board"
        column < SIZE or raise ArgumentError, "there are only #{SIZE} columns on a Sudoku board"
	    update_square_without_solve(value, position1 * SIZE + position2)
	  end
	  solve(false)
    end

    def solve(try_guesses = true, last_solution_count = WHOLE_BOARD_SIZE)
      puts "solve"
      unsolved_count = WHOLE_BOARD_SIZE
	  
	  (0..SIZE).each do |position|
	    unless @board[position].value.nil?
		    delete_possibility_from_row(position, @board[position].value)
            delete_possibility_from_column(position, @board[position].value)
            delete_possibility_from_block(position, @board[position].value)
			unsolved_count -= 1
          end
        end
      end

      puts "unsolved #{unsolved_count}"
      if unsolved_count
        reduce_rows
        reduce_columns
        reduce_blocks
      end

      return solve(try_guesses, unsolved_count) if unsolved_count != last_solution_count
      #return guess(unsolved_count) if try_guesses && unsolved_count > 0
      pp
      return unsolved_count
    end
    
	# currently broken -- need to override clone
	def guess(return_value = 81)
      position = @board.find_index { |square| square.possibilities.length == 2 }
	  position ||= @board.find_index { |square| square.possibilities.length > 1 }
      raise SolvingError, "asked to guess on a solved board" unless position
      puts "guessing for #{position / SIZE},#{position - position / SIZE}"
      test_boards = []
      @board[position].possibilities.each do |possibility|
        puts "guessing value #{possibility}"
        test_boards.push(b.clone)
        begin
          return_value = test_boards[-1].update_and_solve(position,possibility)
          puts "result of guessing #{possibility} for #{position/SIZE},#{position - position/SIZE}"
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

    def delete_possibility_from_row(position, value)
	  rowstart = position - position % SIZE
      (0..SIZE-1).each do |offset|
        @board[rowstart + offset].delete_possibility(value)
      end
    end
    
    def delete_possibility_from_column(position, value)
	  columnstart = position % SIZE
      (0..SIZE-1).each do |offset|
        @board[columnstart + offset * SIZE].delete_possibility(value)
      end
    end
    
	def delete_possibility_from_block(position, value)
	  rowstart = position - position % SIZE
	  columnstart = position % SIZE
	  leftmost_column_in_bock = columnstart - columnstart % SMALL_BLOCK_SIZE
	  topmost_row_in_block = rowstart - (rowstart / SIZE) % SMALL_BLOCK_SIZE * SIZE
      (0..SMALL_BLOCK_SIZE - 1).each do |row_offset|
        (0..SMALL_BLOCK_SIZE - 1).each do |column_offset|
          @board[topmost_row_in_block + row_offset * SIZE + columnstart + column_offset].delete_possibility(value)
        end
      end
    end
        
    # pickup here
    
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
