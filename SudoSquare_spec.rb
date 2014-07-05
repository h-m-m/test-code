require 'minitest/autorun'
require './SudoSquare.rb'


describe :Square do
  before do
    @sq = SudokuSolver::Square.new(9)
    @bigsq = SudokuSolver::Square.new(16)
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

  it "does not allow you to delete the last possibility" do
    (2..9).each { |d| @sq.delete_possibility d }
    proc {@sq.delete_possibility 1}.must_raise(RuntimeError,StandardError)
    @sq.possibilities.length.must_equal 1
  end

  it "has a method that won't let you set it to a value there's no possibility for" do
    (1..3).each { |d| @sq.delete_possibility d }
    @sq.update_value_if_valid(2).must_equal false
  end

  it "can provide a string representation that is constant width regardless of value" do
    @sq.to_s.must_equal '*'
    @bigsq.maximum_width_of_to_s.must_equal 2
    @bigsq.to_s.must_equal '**'
    @bigsq.value = 9
    @bigsq.to_s.must_equal ' 9'
    @bigsq.value = 13
    @bigsq.to_s.must_equal '13'
  end

end
