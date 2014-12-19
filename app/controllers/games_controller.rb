# require_relative '../models/constants'

class GamesController < ApplicationController
	# shows list of all players and their scores
	def index
		@users = User.all
	end

	# player can creata a new game
	def new
		@game = current_user.games.create(status: "new" )	
	end

	# players can view new, currently open (not-started) games to join
	def join
		@games = Game.where(status: "new")
		@number_of_games = @games.count
	end

	# joining players wait for game to be started
	def wait
		@game = Game.find(params[:id])
		p = Player.create(:user_id => current_user.id, :game_id => @game.id)
		p.add_player_to_game		
	end

	# sets up a new game, sends message to waiting players to begin
	def begin
		game = Game.find(params[:id])
		game.update(status: "started")
		response = FIREBASE.push("games/" + game.id.to_s + "/begin/", { :name => "true", :priority => 1 })
		redirect_to play_path(game.id)
	end

	# main game logic 
	def play
		@game = Game.find(params[:id])
		@players = @game.users
	end

end
