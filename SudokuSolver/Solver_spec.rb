require 'minitest/autorun'
require './SudoSolver.rb'
require './SudoBoard.rb'

MiniTest::Assertions.diff=nil

describe :Solver do
  before do
    @hard_board_str = <<EOF
 * 8 9 | * * * | * 6 *
 4 * * | * 1 * | * * 7
 * * * | 9 * * | * 5 *
----------------------
 * 4 * | 7 * * | 6 * *
 7 * * | * * * | * * 8
 * * 5 | * * 6 | * 7 *
----------------------
 * 3 * | * * 4 | * * *
 1 * * | * 7 * | * * 2
 * 2 * | * * * | 9 3 *
EOF
    @hard_board_solution_str = <<EOF
 3 8 9 | 4 5 7 | 2 6 1
 4 5 2 | 6 1 3 | 8 9 7
 6 7 1 | 9 8 2 | 4 5 3
----------------------
 8 4 3 | 7 9 1 | 6 2 5
 7 9 6 | 2 3 5 | 1 4 8
 2 1 5 | 8 4 6 | 3 7 9
----------------------
 9 3 8 | 5 2 4 | 7 1 6
 1 6 4 | 3 7 9 | 5 8 2
 5 2 7 | 1 6 8 | 9 3 4
EOF

    @hard_board_hash = {
      [1,2] => 8, [1,3] => 9, [1,8] => 6, 
      [2,1] => 4, [2,5] => 1, [2,9] => 7, 
      [3,4] => 9, [3,8] => 5,
      [4,2] => 4, [4,4] => 7, [4,7] => 6,
      [5,1] => 7, [5,9] => 8,
      [6,3] => 5, [6,6] => 6, [6,8] => 7,
      [7,2] => 3, [7,6] => 4,
      [8,1] => 1, [8,5] => 7, [8,9] => 2,
      [9,2] => 2, [9,7] => 9, [9,8] => 3
    }

    @hard_board = SudokuSolver::Board.new(9,@hard_board_hash)
    @solver = SudokuSolver::Solver.new
  end
  
  it "can accept a board and return a solved copy" do
    @new_board = @solver.solve(@hard_board)
    @new_board.inspect.must_equal @hard_board_solution_str
  end
  
  it "can accept the board and solve it in place" do
    @solver.solve!(@hard_board)
    puts @hard_board.inspect
    @hard_board.inspect.must_equal @hard_board_solution_str
  end
end


