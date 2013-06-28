# This represents a single game (3x3 grid)

class Grid

  def initialize(state=nil)
    @squares = [nil,nil,nil].fill [nil,nil,nil]

    if state
      # Load the state
      self.load_state state
    end
  end

  # Move (:X, :O, nil)
  def move(row, col, letter=nil)
    @squares[row][col] = letter
  end

  # Is this board full?
  def full?
    @squares.flatten.index(nil).nil?
  end

  # Who won?
  def winner
    @winner ||= find_winner
  end

  def to_a

  end


  private

  def load_state(state)

  end

  # Check if a specific player has won
  def winner?(letter=:X)
    win_arr = [letter, letter, letter]

    # check rows
    return true unless @squares.index(win_arr).nil?

    # check columns
    return true unless @squares.index(win_arr).nil?
  end


  def find_winner
    winning_patterns =
      [[(/OOO....../), [0,1,2], :O], [(/...OOO.../), [3,4,5], :O],
       [(/......OOO/), [6,7,8], :O], [(/O..O..O../), [0,3,6], :O],
       [(/.O..O..O./), [1,4,7], :O], [(/..O..O..O/), [2,5,8], :O],
       [(/O...O...O/), [0,4,8], :O], [(/..O.O.O../), [2,4,6], :O],
       [(/XXX....../), [0,1,2], :X], [(/...XXX.../), [3,4,5], :X],
       [(/......XXX/), [6,7,8], :X], [(/X..X..X../), [0,3,6], :X],
       [(/.X..X..X./), [1,4,7], :X], [(/..X..X..X/), [2,5,8], :X],
       [(/X...X...X/), [0,4,8], :X], [(/..X.X.X../), [2,4,6], :X]
     ]

    flatboard = @squares.flatten.map do |square|
      case square
      when nil then ' '
      when :X then 'X'
      when :O then 'O'
      end
    end

    array = winning_patterns.find { |p| p.first =~ flatboard.join }
    if array
      # @winner = (array.last === :X) ? 'X' : 'O'
      # @win_moves = array[1]
      return array.last
    end
    return nil
  end

end