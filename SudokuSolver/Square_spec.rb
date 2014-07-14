require 'minitest/autorun'
require './Square.rb'


describe :Square do
  before do
    @sq = SudokuSolver::Square.new(9)
    @bigsq = SudokuSolver::Square.new(16)
    @sq4 = SudokuSolver::Square.new(9,4)
    @bigsq11 = SudokuSolver::Square.new(16,11)
  end

  it "has a size that determines max value" do
    @bigsq.value = 16
    proc {@sq.value = 10}.must_raise(ArgumentError,RuntimeError)
  end

  it "can return an array of possible values, starting from 1 through size" do
    @sq.possibilities.must_equal [1,2,3,4,5,6,7,8,9]
    @bigsq.possibilities.must_equal [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
  end

  it "reduces the possibility list if a value is set" do
    @bigsq.value = 4
    @bigsq.possibilities.must_equal [4]
  end
  
  it "allows possibilities to be deleted" do
    @sq.delete_possibility(1)
    @sq.possibilities.must_equal [2,3,4,5,6,7,8,9]
  end

  it "sets the value when all but one possibility is deleted" do
    (1..8).each { |d| @sq.delete_possibility d }
    @sq.value.must_equal 9
  end

  it "returns false if you try to delete the last possibility" do
    (2..9).each { |d| @sq.delete_possibility d }
    @sq.delete_possibility(1).must_equal false
    @sq.possibilities.length.must_equal 1
  end

  it "won't let you set it to a value there's no possibility for" do
    (1..3).each { |d| @sq.delete_possibility d }
    proc {@sq.value=2}.must_raise(RuntimeError)
  end

  it "can provide a string representation that is constant width regardless of value" do
    @sq.to_s.must_equal '*'
    @bigsq.maximum_width_of_to_s.must_equal 2
    @bigsq.to_s.must_equal '**'
    @bigsq.value = 9
    @bigsq.to_s.must_equal ' 9'
    @bigsq2 = SudokuSolver::Square.new(16)
    @bigsq2.value = 13
    @bigsq2.to_s.must_equal '13'
  end
  it "clones its value and possibility list when cloned" do
    @sq.delete_possibility(4)
    @new_sq = @sq.clone
    @new_sq.delete_possibility(2)
    @new_sq.possibilities.index(4).must_be_nil
    @sq.possibilities.index(2).wont_be_nil
    @new_sq4 = @sq4.clone
    @new_sq4.value.must_equal 4
    @new_sq4.possibilities.must_equal [4]
  end
end
