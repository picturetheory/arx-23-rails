# require_relative '../models/constants'

class GamesController < ApplicationController
	# shows list of all players and their scores
	def index
		@users = User.all
	end

	# player can create a new game
	def new
		@game = current_user.games.create(status: "new" )
		@game.players.first.add_initial_player_to_game
	end

	# players can view new, currently open (not-started) games to join
	def join
		@games = Game.where(status: "new")
		@number_of_games = @games.count
	end

	# joining players must wait for game to be started
	def wait
		@game = Game.find(params[:id])
		p = Player.create(:user_id => current_user.id, :game_id => @game.id, :status => "init")
		p.add_player_to_game		
	end

	# sets up a new game, sends message to waiting players to begin
	def begin
		game = Game.find(params[:id])
		game.update(status: "started")

		response = FIREBASE.push("games/" + game.id.to_s + "/play/", { :name => "true", :priority => 1 })		
		
		# set up the game, deal two cards to each player
		deck = Deck.new(game.id)
		players = game.players
		players.each do |player|
			player.create_hand
			player.get_new_card(deck.deal_card)
			player.get_new_card(deck.deal_card)			
		end
		game.set_current_player(players.first.user.id)

		redirect_to play_path(game.id)
	end

	# main game logic 
	def play		
		@game = Game.find(params[:id])				
		@current_player = @game.get_current_player.to_i
		@players = @game.players
	end

end
