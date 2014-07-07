module SudokuSolver
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
        board.rows.each {|row| reduce_single_possibilities_in(row,board.size)}
        board.columns.each {|column| reduce_single_possibilities_in(column,board.size)}
        board.blocks.each {|block| reduce_single_possibilities_in(block,board.size)}
      end

      if unsolved_count < last_solution_count
        solve!(board,unsolved_count)
      else
        board
      end
    end
    
    def reduce_single_possibilities_in(list, size, listname = nil)
      possibility_counts = Array.new(size) {Array.new}
      list.each do |square|
        square.possibilities.each do |value|
          possibility_counts[value - 1] << square
          end
        end

      possibility_counts.each_index do |index|
        possibility_counts[index].length == 0 and raise SolvingError, list_name ? "cannot put a #{value} in #{list_name}" : "missing a place to put a #{value}"
        possibility_counts[index].length == 1 and possibility_counts[index][0].value = index + 1
      end
    end
    
  end
end


