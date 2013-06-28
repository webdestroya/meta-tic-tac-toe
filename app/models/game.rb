class Game < ActiveRecord::Base

  validates_presence_of   :short_code

  validates_presence_of   :game_state

  after_initialize   :default_values

  def default_values
    return if self.short_code.nil?

    self.short_code = SecureRandom.hex

    # Initialize an empty array
    self.game_state = GameState.new
    9.times.to_a.fill { |i| 9.times.to_a.fill('') }
  end



  def state
    # Return the array of arrays that represents the state
    g_state = {
      turn: 'X',
      board: self.board
    }



    g_state
  end

  def board
    @board ||= self.build_board
  end


  # private

  def build_board
    single_grid = [ 
      [' ', ' ', ' '], 
      [' ', ' ', ' '], 
      [' ', ' ', ' '] 
    ]

    [1,1,1].fill do |r|
      [1,1,1].fill do |c|
        single_grid
      end
    end
  end

end
