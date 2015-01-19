class Player < ActiveRecord::Base
	belongs_to :user
	belongs_to :game

	def add_initial_player_to_game
		REDIS.rpush game_key + "/players/", self.id.to_s
	end

	def add_player_to_game
		REDIS.rpush game_key + "/players/", self.id.to_s
		#response = FIREBASE.push("games/" + self.game.id.to_s + "/players/", { :name => self.user.email, :priority => 1 })
    response = self.game.firebase("push", "/players/", self.user.email)
	end

	def create_hand
		clear_hand
		#self.status = "play"
		self.update(status: "play")
	end

	def clear_hand
		REDIS.del player_key
	end

	def get_new_card(card)
		REDIS.rpush player_key, card.to_json
	end

	def total_num_cards
		REDIS.lrange(player_key, 0, -1).count
	end

	def total_value_cards
		REDIS.lrange(player_key, 0, -1).inject(0) do |result, card| 
			result + Card.from_json(card).card_number
		end
	end

	def output_hand
		REDIS.lrange(player_key, 0, -1).collect do |card|
			Card.from_json(card).output_card
		end
	end

  def is_cpu_player    
    if self.user.cpu_player == true
      return true
    else
      return false
    end
  end

  def make_decision(player_action, deck)
    if is_cpu_player
      player_action = cpu_make_decision
    end

    if player_action == "hit" && self.status == "play"
      self.get_new_card(deck.deal_card)
      if self.total_value_cards == 21
        self.update(status: "hold")
      elsif self.total_value_cards > 21
        self.update(status: "bust")
      end
    elsif player_action == "hold"
      self.update(status: "hold")
    else
      #
    end
  end

  def cpu_make_decision 
    if self.total_value_cards > 18
      "hold"
    else
      "hit"
    end   
  end

	private 

		def player_key
			return "game/" + self.game.id.to_s + "/player/" + self.user.id.to_s
		end

		def game_key
			return "game/" + self.game.id.to_s
		end

end
