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
		init_game(game.id)		
		response = FIREBASE.push("games/" + game.id.to_s + "/play/", { :name => "true", :priority => 1 })		
		redirect_to play_path(game.id)
	end

	# main game view controller
	def play		
		@game = Game.find(params[:id])				
		@current_player = @game.get_current_user_id
		@players = @game.players
	end

	# logic for game turn
	def turn
		game = Game.find(params[:id])
		deck = Deck.fetch_deck(game.id)
		player = Player.find(game.get_current_player_id)
		player_action = params[:turn]

		if player_action == "hit" && player.status == "play"
			player.get_new_card(deck.deal_card)
			if player.total_value_cards == 21
				player.update(status: "hold")
			elsif player.total_value_cards > 21
				player.update(status: "bust")
			end
		elsif player_action == "hold"
			player.update(status: "hold")
		else
			#
		end

		# look for next player who's still in the game
		looking_for_next_player = true
		number_of_players = game.get_number_of_players
		count = 0

		while looking_for_next_player
			game.move_to_next_player
			next_player = Player.find(game.get_current_player_id)
			if next_player.status == "play"
				looking_for_next_player = false
			else
				count += 1
			end
			# if a full loop is done then end the game
			if count > number_of_players
				game.update(status: "ended")			
				looking_for_next_player = false				
			end
		end

		if game.status == "ended"
			redirect_to finish_path(game.id)
		else
			redirect_to play_path(game.id)
		end
	end

	# end of game view controller
	def finish
		@game = Game.find(params[:id])				
		@current_player = @game.get_current_user_id		
		@players = @game.players

		result = []
		@players.each do |player|
			if player.total_value_cards > 21
				result << 100
			else
				result << 21 - player.total_value_cards
			end
		end
		winning_score = result.min
		@winner = []
		result.each_with_index do |r, index|
			if r == winning_score
				@players[index].status = "winner"
				@players[index].score = @players[index].score.to_i + 1
			end
		end
		# init_game(@game.id)
	end

	private

		def init_game(game_id)
			game = Game.find(game_id)
			game.update(status: "started")

			# set up the game, deal two cards to each player
			deck = Deck.new(game.id)
			players = game.players
			players.each do |player|
				player.create_hand
				player.get_new_card(deck.deal_card)
				player.get_new_card(deck.deal_card)			
			end
			game.set_current_player(players.first.id)
		end

end
