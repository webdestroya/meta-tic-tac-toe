class GameState

  def initialize(state=nil)
    @grids = [0,0,0].fill do |i|
      [0,0,0].fill{|x| Grid.new}
    end

    if state
      self.load_state state
    end
    
  end


  # Is the game over?
  def over?

  end

  # Get the winner
  def winner

  end

  # Export the state to be loaded into the database
  def export

  end

  # Return the game state as a json object
  def to_json

  end


  private

  def load_state(state)
  end



end