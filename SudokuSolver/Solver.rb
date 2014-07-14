module SudokuSolver

  class SolvingError < StandardError
  end

  class Solver

    def intialize
    end
    def solve(board)
    end
    
    def solve!(board, last_solution_count = board.size * board.size)
      unsolved_count = board.size * board.size
      board.coordinate_list.each do |coordinate|
        value_at_position = board.square(*coordinate).value
        unless value_at_position.nil?
          unsolved_count -= 1
          board.row(coordinate[0]).each do |square| 
            square.delete_possibility(value_at_position)
          end
          board.column(coordinate[1]).each do |square|
            square.delete_possibility(value_at_position)
          end
          board.block_around(*coordinate).each do |square|
            square.delete_possibility(value_at_position)
          end
        end
      end
      
      if unsolved_count > 0
        board.rows.each {|row| reduce_single_possibilities_in(row,board.size, "row #{row}")}
        board.columns.each {|column| reduce_single_possibilities_in(column,board.size,"column #{column}")}
        board.blocks.each {|block| reduce_single_possibilities_in(block,board.size,"block #{block}")}
        if unsolved_count < last_solution_count
          solve!(board,unsolved_count)
        else
          guess(board,unsolved_count)
        end
      else
        board
      end
    end
    
    def reduce_single_possibilities_in(list, size, list_name = nil)
      possibility_counts = Array.new(size) {Array.new}
      list.each do |square|
        square.possibilities.each do |value|
          possibility_counts[value - 1] << square
          end
        end

      possibility_counts.each_index do |index|
        if possibility_counts[index].length == 0
          raise SolvingError, list_name ? "cannot put a #{index + 1} in #{list_name}" : "missing a place to put a #{index + 1}"
        end
        if possibility_counts[index].length == 1
          possibility_counts[index][0].value = index + 1
        end
      end
    end
    
    def guess(board,unsolved_count = board.size ** 2)
      position = board.coordinate_list.find do |coordinate|
        board.square(*coordinate).possibilities.length == 2
      end
      position ||= board.coordinate_list.find do |coordinate|
        board.square(*coordinate).possibilities.length > 1
      end
      position or raise SolvingError, "asked to guess on a solved board"
      
      test_boards = []
      board.square(*position).possibilities.each do |guessing_value|
        test_boards.push(board.clone)
        begin
          test_boards[-1].square(*position).value = guessing_value
          solve!(test_boards[-1],unsolved_count - 1)
        rescue SolvingError => ex
          test_boards.pop
        end
      end
      if test_boards.length > 0
        return test_boards[0] 
      else
        raise SolvingError, "no guesses valid"
      end
    end
    
  end
end


