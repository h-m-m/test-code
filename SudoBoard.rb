module SudokuSolver
  
  class SudoBoard
    
  SIZE = 9
  WHOLE_BOARD_SIZE = SIZE * SIZE
  SMALL_BLOCK_SIZE = 3 # or Math.sqrt(SIZE).floor 
	
    class SolvingError < StandardError
    end

    class SudoSquare
      attr_accessor :value, :possibilities
      
      def initialize(possibilities = nil)
        if possibilities == nil
          @possibilities =(1..SIZE).to_a 
          @value = nil
        else
          raise ArgumentException if not possibilities.is_a?(Array) and possibilities.length > SIZE
          # raise ArguemntException if possibilities.find() for value not from 1 through SIZE
          @possibilities = possibilities
          @possibilities.length == 1 ? @value = @possibilities[0] : @value = nil
        end
      end
      
      def clone
        return SudoSquare.new(@possibilities.clone)
      end
      
      
      def delete_possibility(number)
        test_value(number)
        return if @possibilities == [number]
        @possibilities.delete(number)
        value.nil? and @possibilities.length == 1 and @value = @possibilities[0]
      end
      
      def set_possibility(number)
        test_value(number)
        @possibilities = [number]
        @value = number
      end
      
      def test_value(number)
        number.is_a?(Fixnum)
        number > 0 and number <= SIZE or raise ArgumentError, "sudoku only uses numbers from 1 through #{SIZE}"
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
        @board ||= Array.new( WHOLE_BOARD_SIZE ) { SudoSquare.new }
      end
    end
	
    def valid_board_array?(board)
      board.is_a?(Array) or return false
      board.length == WHOLE_BOARD_SIZE or return false
      board.index { |entry| not entry.is_a?(SudoSquare) } or return true
    end
    
    def clone
      return SudoBoard.new( Array.new(WHOLE_BOARD_SIZE) { |index| @board[index].clone })
    end
    
    def rows(return_squares = false)
      (0..SIZE-1).collect do |index| 
        return_squares ? @board[index * SIZE] : index * SIZE
      end
    end
	
    def columns(return_squares = false)
      return_squares ? @board[0..SIZE-1] : (0..SIZE-1)
    end
	
    def blocks(return_squares = false)
      result =
        (0..SMALL_BLOCK_SIZE-1).collect do |columns|
          (0..SMALL_BLOCK_SIZE-1).collect do |rows|
            block_corner = columns * SMALL_BLOCK_SIZE + rows * SIZE * SMALL_BLOCK_SIZE
            return_squares ? @board[block_corner] : block_corner
          end
        end
      result.flatten
    end
	
    def locations_in_same_row(position, return_squares = false)
      rowstart = position - position % SIZE
      return_squares ? @board[rowstart, SIZE] : (rowstart...rowstart + SIZE)
    end

    def locations_in_same_column(position, return_squares = false)
      columnstart = position % SIZE
      return Array.new(SIZE) do |index|
        boardindex = columnstart + index * SIZE
        return_squares ? @board[boardindex] : boardindex
      end
    end
	
    def locations_in_same_small_block(position, return_squares = false)
      position_rowstart = position - position % SIZE
      position_columnstart = position % SIZE
      block_top_left_rowstart = position_rowstart - (position_rowstart / SIZE) % SMALL_BLOCK_SIZE * SIZE
      block_top_left_columnstart = position_columnstart - position_columnstart % SMALL_BLOCK_SIZE
      result = 
        (0..SMALL_BLOCK_SIZE-1).collect do |row_offset|
          (0..SMALL_BLOCK_SIZE-1).collect do |column_offset|
            boardindex = block_top_left_rowstart + row_offset * SIZE + block_top_left_columnstart + column_offset and
            return_squares ? @board[boardindex] : boardindex
          end
        end
      return result.flatten
    end

    def update(value,position)	  
      @board[position].set_possibility(value)
    end
	
    def update_and_solve(value, position1, position2 = nil)
      if position2.nil?
        position1 < WHOLE_BOARD_SIZE or raise ArgumentError, "there are only #{WHOLE_BOARD_SIZE} rows on the Sudoku board"
        update(value, position1)
      else
        position1 < SIZE or raise ArgumentError, "there are only #{SIZE} rows on the Sudoku board"
        position2 < SIZE or raise ArgumentError, "there are only #{SIZE} columns on the Sudoku board"
        update(value, position1 * SIZE + position2)
      end
      solve(false)
    end

    def solve(try_guesses = true, last_solution_count = WHOLE_BOARD_SIZE)
      unsolved_count = @board.length
	  
      @board.each_index do |position|
        value = @board[position].value
        unless value.nil?
          locations_in_same_row(position, :squares).each { |square| square.delete_possibility(value) }
          locations_in_same_column(position, :squares).each { |square| square.delete_possibility(value) }
          locations_in_same_small_block(position, :squares).each { |square| square.delete_possibility(value) }
          unsolved_count -= 1
        end
      end
    
      if unsolved_count
        columns.each {|location| reduce_single_possibilities_in(locations_in_same_column(location), "column #{location + 1}")}
        rows.each {|location| reduce_single_possibilities_in(locations_in_same_row(location), "row #{location / SIZE + 1}")}
        blocks.each {|location| reduce_single_possibilities_in(locations_in_same_small_block(location))}
      end
    
      return solve(try_guesses, unsolved_count) if unsolved_count != last_solution_count
      #return guess(unsolved_count) if try_guesses && unsolved_count > 0
      pp
      return unsolved_count
    end
  
    def reduce_single_possibilities_in(list, list_name = nil)
      possibility_counts = Array.new(SIZE) {Array.new}
      list.each do |position|
        @board[position].possibilities.each do |value|
          possibility_counts[value - 1] << position
        end
      end
    
      possibility_counts.each_index do |index|
        value = index + 1
        possibility_counts[index].length == 0 and raise SolvingError, list_name ? "cannot put a #{value} in #{list_name}" : "missing a place to put a #{value}"
        possibility_counts[index].length == 1 and update(value,possibility_counts[index][0])
      end
    end
    
    def guess(return_value = 81)
      position = @board.find_index { |square| square.possibilities.length == 2 }
      position ||= @board.find_index { |square| square.possibilities.length > 1 }
      raise SolvingError, "asked to guess on a solved board" unless position
      puts "guessing for #{position / SIZE},#{position % SIZE}"
      test_boards = []
      @board[position].possibilities.each do |possibility|
        puts "guessing value #{possibility}"
        test_boards.push(self.clone)
        begin
          test_boards[-1].update_and_solve(possibility,position)
          puts "result of guessing #{possibility} for #{position/SIZE},#{position % SIZE}"
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
    
    def to_a
      @board
    end

    def pp
      max_char_width = SIZE / 10 + 1
      digit_format = "%" + max_char_width.to_s + "d"
      @board.each_index do |position|
        print @board[position].value ? sprintf(digit_format, @board[position].value) : "*" * max_char_width
        print " "
        next if position == 0 or position == WHOLE_BOARD_SIZE - 1
        if (position + 1) % SIZE == 0
          puts
          if (position + 1) / SIZE % SMALL_BLOCK_SIZE == 0
            puts "-" * (max_char_width * SIZE + SIZE + 2 * (SMALL_BLOCK_SIZE - 1))
          end
        else
          print "| " if (position + 1) % SMALL_BLOCK_SIZE == 0
        end
      end
      puts
    end
  end
end


__END__

 b = SudokuSolver::SudoBoard.new
  b.update_and_solve(8,0,1)
  b.update_and_solve(9,0,2)
  b.update_and_solve(6,0,7)
  b.update_and_solve(4,1,0)
  b.update_and_solve(1,1,4)
  b.update_and_solve(7,1,8)
  b.update_and_solve(9,2,3)
  b.update_and_solve(5,2,7)
  b.update_and_solve(4,3,1)
  b.update_and_solve(7,3,3)
  b.update_and_solve(6,3,6)
  b.update_and_solve(7,4,0)
  b.update_and_solve(8,4,8)
  b.update_and_solve(5,5,2)
  b.update_and_solve(6,5,5)
  b.update_and_solve(7,5,7)
  b.update_and_solve(3,6,1)
  b.update_and_solve(4,6,5)
  b.update_and_solve(1,7,0)
  b.update_and_solve(7,7,4)
  b.update_and_solve(2,7,8)
  b.update_and_solve(2,8,1)
  b.update_and_solve(9,8,6)
  b.update_and_solve(3,8,7) 
