class Player < ActiveRecord::Base
	belongs_to :user
	belongs_to :game


	def add_player_to_game
		response = FIREBASE.push("games/" + self.game.id.to_s + "/players/", { :name => self.user.email, :priority => 1 })
	end

	def create_hand
		clear_hand
		self.status = 0		# 0 = playing, 1 = hold, 2 = bust
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

	private 

		def player_key
			return "game/" + self.game.id.to_s + "/player/" + self.user.id.to_s
		end

end
