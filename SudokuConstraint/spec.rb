require 'minitest/autorun'

describe :Square do
  it "has a value that can be set"
  it "has a list of possible values"
  it "reduces the list of possible values to one if you set the value"
  it "lets you delete a possibility from its list"
  it "automatically sets the value if only one possibility remains"
  it "won't delete the last possibility" #not sure if this needs to raise an error
  it "will raise an error if you try to set the value to something not in the possibility list"
  it "has a list of objects that can constrain it"
  it "updates those constraints when its value updates"
  it "undoes a value or possibility update if a constraint raises an error when notified, and it passes that error back to the original caller"
end

describe :Constraint do
  it "keeps track of a list of objects that it constrains"
  it "keeps track of values set on the objects it constrains"
  it "keeps track of possible values on the objects it constrains"
  it "will remove a value from the possibility lists of the other constrained objects if one of them sends a notification that the value is spoken for"
  it "will set an constrained object's value if that is the only object in the Constraint's list that still has that value as a possibility"
  it "will raise an error back to the notifying object if acting on that notification raised an error"
end

describe :Board do
  it "creates a board of a valid sudoku board size"
  it "tells each square what its initial possibilities are based on board size"
  it "can accept a list of coordinate/value pairs and use them to update the squares in the board"
  it "keeps track of how many squares have set values"
  it "can create a board with or without constraints"
  it "creates row, column, and block constraint objects for each new constrained board"
  it "can print out a legible board as a string"
  it "reflects updates when the board is printed"
  it "can try and solve a board with constraints"
end


