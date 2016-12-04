class XboxController < ApplicationController
  before_filter :setup_xbox_key

  # /xbox/games/:id/:xuid
  def user
    @gamer_tag = params[:gamer_tag]
    xuid = params[:xuid]
    @gamer = XboxGamer.find(:tag => @gamer_tag, :id => xuid)
  end

  #/xbox/game/:id
  def game
    @id = params[:id]
    @game = XboxGame.find(:id => @id)
  end

  def compare
    @gamers = []

    unless params[:names].blank?
      names = params[:names].to_s.split(',')
      @gamers = names.collect { |name| XboxGamer.find(:tag => name) }

      @full_one_games = []
      @full_360_games = []

      @games_one_compare = Hash.new { |h, k| h[k]=[] }
      @games_360_compare = Hash.new { |h, k| h[k]=[] }
      @gamers.each do |gamer|
        gamer.games_one.compact.each do |game|
          @games_one_compare[game.name] << gamer
          @full_one_games << game
        end
        gamer.games_360.compact.each do |game|
          @games_360_compare[game.name] << gamer
          @full_360_games << game
        end
      end
      @full_360_games = @full_360_games.compact.uniq { |x| x.name }
      @full_one_games = @full_one_games.compact.uniq { |x| x.name }
    end
  end
end