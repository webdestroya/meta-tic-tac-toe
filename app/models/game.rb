class Game < ActiveRecord::Base

  validates_presence_of   :short_code

  validates_presence_of   :game_state

  after_initialize   :default_values
  after_find         :unserialize_state
  before_save        :serialize_state

  def default_values
    return unless self.short_code.nil?

    self.short_code = SecureRandom.hex
    self.turn = "X"
    # Initialize an empty array
    self.game_state = self.build_board
    self.overall_score = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '] 
  end



  def state
    # Return the array of arrays that represents the state
    g_state = {
      turn: self.turn,
      overall_score: self.overall_score,
      board: self.game_state,
      finished: self.finished?,
      winner: self.winner
    }
    g_state
  end

  def board
    @board ||= self.build_board
  end


  def unserialize_state
    self.game_state = ActiveSupport::JSON.decode(self.game_state)
    self.overall_score = ActiveSupport::JSON.decode(self.overall_score)
  end

  def serialize_state
    self.game_state = self.game_state.to_json
    self.overall_score = self.overall_score.to_json
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
