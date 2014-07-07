require 'minitest/autorun'
require './Board.rb'

MiniTest::Assertions.diff =nil

describe :Board do
  it "creates a 9x9 board of squares by default" do
    @board = SudokuSolver::Board.new
    @board.size.must_equal 9
    @board.square(9,9).wont_be_nil
    @board.square(1,1).wont_be_nil
    proc {@board.square(16,16)}.must_raise ArgumentError
    proc {@board.square(25,25)}.must_raise ArgumentError
    proc {@board.square(26,26)}.must_raise ArgumentError
    proc {@board.square(0,0)}.must_raise ArgumentError
  end
  
  it "creates any arbitrary square board" do
    @board = SudokuSolver::Board.new(16)
    @board.size.must_equal 16
    @board.square(1,1).wont_be_nil
    @board.square(16,16).wont_be_nil
    proc {@board.square(25,25)}.must_raise ArgumentError
    proc {@board.square(26,26)}.must_raise ArgumentError
    proc {@board.square(0,0)}.must_raise ArgumentError
    
    @board = SudokuSolver::Board.new(25)
    @board.size.must_equal 25
    @board.square(9,9).wont_be_nil
    @board.square(1,1).wont_be_nil
    @board.square(16,16).wont_be_nil
    @board.square(25,25).wont_be_nil
    proc {@board.square(26,26)}.must_raise ArgumentError
    proc {@board.square(0,0)}.must_raise ArgumentError
    
    proc {SudokuSolver::Board.new(5)}.must_raise ArgumentError
  end
    
  it "prints out a legible board" do
    @board = SudokuSolver::Board.new
    @board.inspect.must_equal <<EOF
 * * * | * * * | * * *
 * * * | * * * | * * *
 * * * | * * * | * * *
----------------------
 * * * | * * * | * * *
 * * * | * * * | * * *
 * * * | * * * | * * *
----------------------
 * * * | * * * | * * *
 * * * | * * * | * * *
 * * * | * * * | * * *
EOF
  end
  
  it "prints out a legible board that reflects updates" do
    @board = SudokuSolver::Board.new
    @board.square(2,3).value = 4
    @board.inspect.must_equal <<EOF
 * * * | * * * | * * *
 * * 4 | * * * | * * *
 * * * | * * * | * * *
----------------------
 * * * | * * * | * * *
 * * * | * * * | * * *
 * * * | * * * | * * *
----------------------
 * * * | * * * | * * *
 * * * | * * * | * * *
 * * * | * * * | * * *
EOF
    @board = SudokuSolver::Board.new(16)
    @board.square(10,5).value = 14
    @board.inspect.must_equal <<EOF
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
------------------------------------------------------
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
------------------------------------------------------
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | 14 ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
------------------------------------------------------
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
 ** ** ** ** | ** ** ** ** | ** ** ** ** | ** ** ** **
EOF
  end
  
  it "can provide a list containing squares in the correct row" do
    @board = SudokuSolver::Board.new
    @board.square(8,7).value = 1
    @row = @board.row(8)
    @row[6].value.must_equal 1
    @row[0].value.must_be_nil
    @row.length.must_equal 9
  end
  
  it "can provide a list containing squares in the correct column" do
    @board = SudokuSolver::Board.new
    @board.square(3,6).value = 6
    @column = @board.column(6)
    @column[2].value.must_equal 6
    @column[8].value.must_be_nil
    @column.length.must_equal 9
  end
  
  it "can provide a list containing squares in the correct block" do
    @board = SudokuSolver::Board.new(16)
    @board.square(10,2).value = 10
    @block = @board.block_around(10,2)
    @block[5].value.must_equal 10
    @block.length.must_equal 16
  end
  
  it "can return a list of all blocks" do
    @board = SudokuSolver::Board.new
    @board.square(1,9).value = 3
    @blocks = @board.blocks
    @board.blocks[0][0].value.must_equal nil
    @board.blocks[2][2].value.must_equal 3
  end

  it "can accept a hash of [coordinates]=>values and use it to populate a board" do
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
    @board = SudokuSolver::Board.new(9,@hard_board_hash)
    @board.inspect.must_equal @hard_board_str
  end

  it "can provide provide a list of every coordinate" do
    @board = SudokuSolver::Board.new
    @test_value = 8
    @test_coordinate = [3,3]
    @found_coordinate = false
    @found_9x9 = false
    @board.square(*@test_coordinate).value = @test_value
    @board.coordinate_list.each do |coord|
      if coord == @test_coordinate
        @board.square(*coord).value.must_equal @test_value
        @found_coordinate = true
      end
      if coord = [9,9]
        @found_9x9 = true
      end
    end
    @found_coordinate.must_equal true
    @found_9x9.must_equal true
  end

  it "clones its squares when it clones itself" do
    @board = SudokuSolver::Board.new
    @board.square(4,8).value = 4
    @new_board = @board.clone
    @new_board.square(4,8).value.must_equal 4
    @new_board.square(3,1).value = 1
    @board.square(3,1).value.must_be_nil
  end
end
