class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update, :expire]

  # GET /games/1
  # GET /games/1.json
  def show
    @game_details = {
      expire_path: expire_game_url(@game)
    }
  end

  # GET /games/new
  def new
    @game = Game.new
    @game.save!

    redirect_to @game
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update

    @game.turn = params[:game][:turn]
    @game.finished = params[:game][:finished]
    @game.winner = params[:game][:winner]
    @game.overall_score = ActiveSupport::JSON.decode(params[:game][:overall_score])
    @game.game_state = ActiveSupport::JSON.decode(params[:game][:game_state])

    respond_to do |format|
      if @game.save
        format.json { head :no_content }
      else
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def expire

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:short_code, :game_state, :overall_score, :turn)
    end
end
