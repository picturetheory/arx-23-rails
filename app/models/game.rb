class Game < ActiveRecord::Base
	has_many :players
	has_many :users, through: :players


	def set_current_player(player_id)
		REDIS.set game_key + "/current_player", player_id
	end

	def move_to_next_player
		players = REDIS.lrange game_key + "/players/", 0, -1
		players << players[0]
		current_player = REDIS.get game_key + "/current_player"
		return_next_player = false
		next_player = nil		

		players.each do |player|
			if return_next_player
				next_player = player
				break		
			end
			if player == current_player
				return_next_player = true
			end
		end
		set_current_player(next_player)
	end

	def get_current_player_id
		return REDIS.get(game_key + "/current_player").to_i
	end

	def get_all_players
		return REDIS.lrange game_key + "/players/", 0, -1
	end

	def get_number_of_players
		return REDIS.lrange(game_key + "/players/", 0, -1).count
	end

	def get_current_user_id
		player = Player.find(REDIS.get(game_key + "/current_player").to_i)
		return player.user.id
	end

  def firebase(action, tag = "")
    if Rails.env.production?
      prefix = "p/"
    else
      prefix = "d/"
    end
    
    if action == "push"
      FIREBASE.push(prefix + "games/" + self.id.to_s + tag, { :name => "true", :priority => 1 })
    elsif action == "delete"
      FIREBASE.delete(prefix + "games/" + self.id.to_s + tag)
    end
  end  

	private 

		def game_key
			return "game/" + self.id.to_s
		end	
end
