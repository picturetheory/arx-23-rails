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

  def about
  end

	# players can view new, currently open (not-started) games to join
	def join
		#@games = Game.where(status: "new", created_at: )
    time_period_for_games = Time.now - 1.hours
    #raise time_period_for_games.to_s
    #raise Game.last.created_at.to_s 
    @games = Game.where("status = 'new' and created_at >= ?", time_period_for_games)
      
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
    
    cpu_player_included = params[:cpu]
    if cpu_player_included == "1"
        cpu_user = User.where(cpu_player: true).first        
        p = Player.create(:user_id => cpu_user.id, :game_id => game.id, :status => "init", :score => 0)
        p.add_player_to_game
    end

		init_game(game.id)
		#FIREBASE.push("games/" + game.id.to_s + "/play/", { :name => "true", :priority => 1 })
    game.firebase("push", "/play/")
		redirect_to play_path(game.id)
	end

	# main game view controller
	def play		
		@game = Game.find(params[:id])
		#FIREBASE.delete("games/" + @game.id.to_s + "/turn/")
    @game.firebase("delete", "/turn/")
		# if game has finished, then start a new one
		if @game.status == "ended"
			init_game(@game.id)
			#FIREBASE.delete("games/" + @game.id.to_s + "/ended/")
      @game.firebase("delete", "/ended/")
		end
		
		@current_user_id = @game.get_current_user_id
		@players = @game.players

    current_player = Player.find(@game.get_current_player_id)    
    if current_player.is_cpu_player && current_player.status == "play"
      redirect_to action: "turn", id: @game.id
    end
	end

	# logic for game turn
	def turn
		game = Game.find(params[:id])
		deck = Deck.fetch_deck(game.id)
		player = Player.find(game.get_current_player_id)
		player_action = params[:turn]		

    player.make_decision(player_action, deck)

		# look for next player who's still in the game
		looking_for_next_player = true
		number_of_players = game.get_number_of_players
    number_of_busted_players = 0
		count = 0

		while looking_for_next_player
			game.move_to_next_player
			new_player = Player.find(game.get_current_player_id)

      if new_player.is_cpu_player && new_player.status == "play"
        redirect_to action: "turn", id: game.id and return
      elsif new_player.status == "play"
				looking_for_next_player = false
			else
        if new_player.status == "bust"
          number_of_busted_players += 1
        end
				count += 1
			end

      # if everyone else is bust then end the game
      if number_of_busted_players == number_of_players - 1
        game.update(status: "ended")      
        looking_for_next_player = false     
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
				if r == winning_score && r < 21
					winner = players[index]
					winner.update(status: "winner")
					winner.update(score: players[index].score.to_i + 1)
					winner_user = winner.user
					winner_user.update(games_won: winner_user.games_won.to_i + 1)
				end
			end
			#FIREBASE.delete("games/" + game.id.to_s + "/turn/")
			#FIREBASE.push("games/" + game.id.to_s + "/ended/", { :name => "true", :priority => 1 })
      game.firebase("delete", "/turn/")
      game.firebase("push", "/ended/")
			redirect_to finish_path(game.id)
		else
			#FIREBASE.push("games/" + game.id.to_s + "/turn/", { :name => "true", :priority => 1 })
      game.firebase("push", "/turn/")
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
      first_non_cpu_player_id = 0

			players.each do |player|
				player.create_hand
				player.get_new_card(deck.deal_card)
				player.get_new_card(deck.deal_card)
        if !player.is_cpu_player && first_non_cpu_player_id == 0
          first_non_cpu_player_id = player.id 
        end
			end
			#game.set_current_player(players.first.id)
      game.set_current_player(first_non_cpu_player_id)
		end

end
