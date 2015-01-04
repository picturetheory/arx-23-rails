class Game < ActiveRecord::Base
	has_many :players
	has_many :users, through: :players


	def set_current_player(user_id)
		REDIS.set game_key + "/current_player", user_id
	end

	def move_to_next_player
		players = REDIS.lrange game_key + "/players/", 0, -1
		players << players[0]
		current_player = REDIS.get game_key + "/current_player"
		return_next_player = false

		players.each do |player|
			if return_next_player
				set_current_player(player.id)
				break
			end
			if player == current_player
				return_next_player = true
			end
		end			
	end

	def get_current_player
		return REDIS.get game_key + "/current_player"
	end

	def get_all_players
		return REDIS.lrange game_key + "/players/", 0, -1
	end

	private 

		def game_key
			return "game/" + self.id.to_s
		end	
end
