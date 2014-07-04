require 'minitest/autorun'
require './SudoBoard.rb'


describe :SudoBoard do
  it "creates a 9x9 board of squares by default" do
    @board = SudokuSolver::SudoBoard.new
    @board.size.must_equal 9
    @board.square(9,9).wont_be_nil
    @board.square(1,1).wont_be_nil
    proc {@board.square(16,16)}.must_raise ArgumentError
    proc {@board.square(25,25)}.must_raise ArgumentError
    proc {@board.square(26,26)}.must_raise ArgumentError
    proc {@board.square(0,0)}.must_raise ArgumentError
  end
  
  it "creates any arbitrary square board" do
    @board = SudokuSolver::SudoBoard.new(16)
    @board.size.must_equal 16
    @board.square(1,1).wont_be_nil
    @board.square(16,16).wont_be_nil
    proc {@board.square(25,25)}.must_raise ArgumentError
    proc {@board.square(26,26)}.must_raise ArgumentError
    proc {@board.square(0,0)}.must_raise ArgumentError
    
    @board = SudokuSolver::SudoBoard.new(25)
    @board.size.must_equal 25
    @board.square(9,9).wont_be_nil
    @board.square(1,1).wont_be_nil
    @board.square(16,16).wont_be_nil
    @board.square(25,25).wont_be_nil
    proc {@board.square(26,26)}.must_raise ArgumentError
    proc {@board.square(0,0)}.must_raise ArgumentError
    
    proc {SudokuSolver::SudoBoard.new(5)}.must_raise ArgumentError
  end
    
  it "prints out a legible board" do
    @board = SudokuSolver::SudoBoard.new
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
    @board = SudokuSolver::SudoBoard.new
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
    @board = SudokuSolver::SudoBoard.new(16)
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
    @board = SudokuSolver::SudoBoard.new
    @board.square(8,7).value = 1
    @row = @board.row(8)
    @row[6].value.must_equal 1
    @row[0].value.must_be_nil
    @row.length.must_equal 9
  end
  
  it "can provide a list containing squares in the correct column" do
    @board = SudokuSolver::SudoBoard.new
    @board.square(3,6).value = 6
    @column = @board.column(6)
    @column[2].value.must_equal 6
    @column[8].value.must_be_nil
    @column.length.must_equal 9
  end
  
  it "can provide a list containing squares in the correct block" do
    @board = SudokuSolver::SudoBoard.new(16)
    @board.square(10,2).value = 10
    @block = @board.block(3,1)
    @block[5].value.must_equal 10
    @block.length.must_equal 16
  end
  
end
