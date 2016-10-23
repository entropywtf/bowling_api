class GamesController < ApplicationController
  before_action :set_game, only: [:submit_score, :score]

  def create
    game = Game.create
    render json: game
  end

  def score
    if params[:submit_score]
      submit_score
    else
      render json: @game
    end
  end

  private

  def set_game
    begin
      @game = Game.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      game = Game.new
      game.errors.add(:id, "Wrong game id provided")
      render_error(game, 404) and return
    end
  end

  def submit_score
    if @game.is_over
      @game.errors.add(:is_over, "Game is over. No more score can be submitted")
      render_error(@game, 304) and return
    else
      @game.update_score(params[:submit_score].to_i)
      render json: @game
    end
  end
end
