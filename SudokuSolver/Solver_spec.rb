require 'minitest/autorun'
require './Solver.rb'
require './Board.rb'

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

    @hard_board = SudokuSolver::Board.new(size: 9, values_hash: @hard_board_hash)
    @solver = SudokuSolver::Solver.new
  end
  
  it "can try and solve a board without guessing" do
    @solver.solve(@hard_board)
    @hard_board.inspect.must_equal <<EOF
 3 8 9 | * * 7 | * 6 1
 4 5 * | * 1 * | * 9 7
 * 7 1 | 9 * * | * 5 3
----------------------
 * 4 3 | 7 * 1 | 6 2 5
 7 * * | * 3 * | 1 4 8
 * 1 5 | * * 6 | 3 7 9
----------------------
 * 3 8 | * * 4 | 7 1 6
 1 * 4 | * 7 * | 5 8 2
 * 2 7 | 1 * * | 9 3 4
EOF

  end

  it "can try and solve a board via reductio ad absurdum" do
    @solver.solve(@hard_board)
    @solver.guess(@hard_board).inspect.must_equal @hard_board_solution_str
  end

  it "will properly reduce lists of squares" do
    def sof9 (value)
      SudokuSolver::Square.new(9,value)
    end
    list = [sof9(1),sof9(2),sof9(3),sof9(nil),sof9(nil),sof9(nil),sof9(nil),sof9(nil),sof9(nil)]
    (4..8).each { |i| list[i].delete_possibility(5)}
    SudokuSolver::Solver.new.reduce_single_possibilities_in(list, 9)
    list[3].value.must_equal 5
  end
end


