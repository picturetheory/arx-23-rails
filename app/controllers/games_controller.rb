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
		p = Player.create(:user_id => current_user.id, :game_id => @game.id, :status => "init", :score => 0)
		p.add_player_to_game		
	end

	# sets up a new game, sends message to waiting players to begin
	def begin
		game = Game.find(params[:id])
		init_game(game.id)		
		FIREBASE.push("games/" + game.id.to_s + "/play/", { :name => "true", :priority => 1 })
		redirect_to play_path(game.id)
	end

	# main game view controller
	def play		
		@game = Game.find(params[:id])
		FIREBASE.delete("games/" + @game.id.to_s + "/turn/")
		# if game has finished, then start a new one
		if @game.status == "ended"
			init_game(@game.id)
			FIREBASE.delete("games/" + @game.id.to_s + "/ended/")
		end
		
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
			# calculate the winners and update scores
			players = game.players
			result = []
			players.each do |player|
				if player.total_value_cards > 21
					result << 100
				else
					result << 21 - player.total_value_cards
				end
			end
			winning_score = result.min			
			result.each_with_index do |r, index|
				if r == winning_score
					winner = players[index]
					winner.update(status: "winner")
					winner.update(score: players[index].score.to_i + 1)
					winner_user = winner.user
					winner_user.update(games_won: winner_user.games_won.to_i + 1)
				end
			end
			FIREBASE.delete("games/" + game.id.to_s + "/turn/")
			FIREBASE.push("games/" + game.id.to_s + "/ended/", { :name => "true", :priority => 1 })
			redirect_to finish_path(game.id)
		else
			FIREBASE.push("games/" + game.id.to_s + "/turn/", { :name => "true", :priority => 1 })
			redirect_to play_path(game.id)
		end
	end

	# end of game view controller
	def finish
		@game = Game.find(params[:id])	
		@players = @game.players		
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
